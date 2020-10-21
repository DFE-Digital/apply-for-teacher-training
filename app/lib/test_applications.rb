class TestApplications
  class NotEnoughCoursesError < RuntimeError; end
  class ZeroCoursesPerApplicationError < RuntimeError; end

  attr_reader :time

  def generate_for_provider(provider:, courses_per_application:, count:)
    1.upto(count).flat_map do
      create_application(
        recruitment_cycle_year: 2021,
        states: [:awaiting_provider_decision] * courses_per_application,
        courses_to_apply_to: Course.current_cycle.includes(:course_options).joins(:course_options).distinct.open_on_apply.where(provider: provider),
      )
    end
  end

  def create_application(recruitment_cycle_year:, states:, courses_to_apply_to:, apply_again: false, course_full: false)
    candidate = nil

    min_days_in_the_past = recruitment_cycle_year == 2020 ? 375 : 10
    travel_to rand(min_days_in_the_past..(min_days_in_the_past + 20)).days.ago

    if apply_again
      raise OnlyOneCourseWhenApplyingAgainError, 'You can only apply to one course when applying again' unless states.one?

      create_application(recruitment_cycle_year: recruitment_cycle_year, states: [:rejected], courses_to_apply_to: courses_to_apply_to)

      candidate = Candidate.last
      first_name = candidate.current_application.first_name
      last_name = candidate.current_application.last_name
    else
      raise ZeroCoursesPerApplicationError, 'You cannot have zero courses per application' unless states.any?

      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      candidate = FactoryBot.create(
        :candidate,
        email_address: "#{first_name.downcase}.#{last_name.downcase}@example.com",
        created_at: time,
        last_signed_in_at: time,
      )
    end

    courses_to_apply_to =
      if course_full
        # Always use the first n courses, so that we can reliably generate
        # application choices to full courses without randomly affecting the
        # vacancy status of the entire set of available courses.
        fill_vacancies(courses_to_apply_to.first(states.size))
      else
        courses_to_apply_to.sample(states.count)
      end

    # it does not make sense to apply to the same course multiple times
    # in the course of the same application, and it's forbidden in the UI.
    # Throw an exception if we try to do that here.
    if courses_to_apply_to.count < states.count
      raise NotEnoughCoursesError, "Not enough distinct courses to generate a #{states.count}-course application"
    end

    Audited.audit_class.as_user(candidate) do
      traits = [%i[with_safeguarding_issues_disclosed
                   with_no_safeguarding_issues_to_declare
                   with_safeguarding_issues_never_asked].sample]
      traits << :with_equality_and_diversity_data if rand < 0.55

      @application_form = FactoryBot.create(
        :completed_application_form,
        *traits,
        application_choices_count: 0,
        full_work_history: true,
        volunteering_experiences_count: 1,
        references_count: 2,
        with_gcses: true,
        with_degree: true,
        submitted_at: nil,
        candidate: candidate,
        first_name: first_name,
        last_name: last_name,
        created_at: time,
        updated_at: time,
        edit_by: time,
        recruitment_cycle_year: recruitment_cycle_year,
        phase: apply_again ? 'apply_2' : 'apply_1',
      )

      fast_forward(1..2)
      application_choices = courses_to_apply_to.map do |course|
        FactoryBot.create(
          :application_choice,
          status: 'unsubmitted',
          course_option: course.course_options.first,
          application_form: @application_form,
          created_at: time,
          updated_at: time,
        )
      end

      if (states.include? :awaiting_references) && course_full
        application_choices.each do |choice|
          create_alternative_locations_and_study_mode(choice) if course_full
        end
      end

      return if states.include? :unsubmitted

      if states.include? :cancelled
        SupportInterface::CancelApplicationForm.new(application_form: @application_form).save!
        return
      end

      without_slack_message_sending do
        fast_forward(1..2)
        SubmitApplicationWithDecoupledReferences.new(@application_form).call

        @application_form.application_choices.each do |choice|
          choice.update_columns(
            sent_to_provider_at: time,
            reject_by_default_at: time + rand(3..30).days,
            updated_at: time,
          )
          choice.audits.last&.update_columns(created_at: time)
        end

        @application_form.update_columns(submitted_at: time, edit_by: time + 7.days, updated_at: time)

        @application_form.application_references.each do |reference|
          reference.relationship_correction = ['', Faker::Lorem.sentence].sample
          reference.safeguarding_concerns = ['', Faker::Lorem.sentence].sample
          reference.safeguarding_concerns_status = reference.safeguarding_concerns.blank? ? :no_safeguarding_concerns_to_declare : :has_safeguarding_concerns_to_declare

          reference.update!(feedback: 'You are awesome')

          SubmitReference.new(
            reference: reference,
          ).save!
        end

        states.zip(application_choices).each do |state, application_choice|
          put_application_choice_in_state(application_choice.reload, state)
        end

        FactoryBot.create(:ucas_match, application_form: @application_form) if rand < 0.5
      end

      application_choices.each do |application_choice|
        rand(0..3).times { add_note(application_choice.reload) }
      end

      application_choices
    end
  end

  def put_application_choice_in_state(choice, state)
    travel_to(choice.application_form.edit_by) if choice.application_form.edit_by > time
    choice.update_columns(updated_at: time)
    choice.audits.last&.update_columns(created_at: time)

    return if state == :awaiting_provider_decision

    case state
    when :offer
      make_offer(choice)
    when :rejected
      reject_application(choice)
    when :offer_withdrawn
      make_offer(choice)
      withdraw_offer(choice)
    when :offer_deferred
      make_offer(choice)
      accept_offer(choice)
      defer_offer(choice)
    when :declined
      make_offer(choice)
      decline_offer(choice)
    when :accepted, :pending_conditions
      make_offer(choice)
      accept_offer(choice)
    when :accepted_no_conditions
      make_offer(choice, conditions: [])
      accept_offer(choice)
    when :conditions_not_met
      make_offer(choice)
      accept_offer(choice)
      conditions_not_met(choice)
    when :recruited
      make_offer(choice)
      accept_offer(choice)
      confirm_offer_conditions(choice)
    when :withdrawn
      withdraw_application(choice)
    end

    choice.update_columns(updated_at: time)
  end

  def accept_offer(choice)
    fast_forward(1..3)
    AcceptOffer.new(application_choice: choice).save!
    choice.update_columns(accepted_at: time, updated_at: time)
    # accept generates two audit writes (minimum), one for status, one for timestamp
    choice.audits.second_to_last&.update_columns(created_at: time)
    choice.audits.last&.update_columns(created_at: time)
  end

  def withdraw_application(choice)
    fast_forward(1..3)
    WithdrawApplication.new(application_choice: choice).save!
    choice.update_columns(withdrawn_at: time, updated_at: time)
    # service generates two audit writes, one for status, one for timestamp
    choice.audits.second_to_last&.update_columns(created_at: time)
    choice.audits.last&.update_columns(created_at: time)
  end

  def decline_offer(choice)
    fast_forward(1..3)
    DeclineOffer.new(application_choice: choice).save!
    choice.update_columns(declined_at: time, updated_at: time)
    choice.audits.last&.update_columns(created_at: time)
    # service generates two audit writes, one for status, one for timestamp
    choice.audits.second_to_last&.update_columns(created_at: time)
    choice.audits.last&.update_columns(created_at: time)
  end

  def make_offer(choice, conditions: ['Complete DBS'])
    as_provider_user(choice) do
      fast_forward(1..3)
      MakeAnOffer.new(
        actor: actor,
        course_option: choice.course_option,
        application_choice: choice,
        offer_conditions: conditions,
      ).save
      choice.update_columns(offered_at: time, updated_at: time)
    end
    choice.audits.last&.update_columns(created_at: time)
  end

  def reject_application(choice)
    as_provider_user(choice) do
      fast_forward(1..3)
      RejectApplication.new(actor: actor, application_choice: choice, rejection_reason: 'Some').save
      choice.update_columns(rejected_at: time, updated_at: time)
    end
    # service generates two audit writes, one for status, one for timestamp
    choice.audits.second_to_last&.update_columns(created_at: time)
    choice.audits.last&.update_columns(created_at: time)
  end

  def withdraw_offer(choice)
    as_provider_user(choice) do
      fast_forward(1..3)
      WithdrawOffer.new(actor: actor, application_choice: choice, offer_withdrawal_reason: 'Offer withdrawal reason is...').save
      choice.update_columns(offer_withdrawn_at: time, updated_at: time)
    end
    choice.audits.last&.update_columns(created_at: time)
  end

  def defer_offer(choice)
    as_provider_user(choice) do
      fast_forward(1..3)
      confirm_offer_conditions(choice) if rand > 0.5 # 'recruited' can also be deferred
      DeferOffer.new(actor: actor, application_choice: choice).save!
      choice.update_columns(offer_deferred_at: time, updated_at: time)
    end
    # service generates two audit writes, one for status, one for timestamp
    choice.audits.second_to_last&.update_columns(created_at: time)
    choice.audits.last&.update_columns(created_at: time)
  end

  def conditions_not_met(choice)
    as_provider_user(choice) do
      fast_forward(1..3)
      ConditionsNotMet.new(actor: actor, application_choice: choice).save
      choice.update_columns(conditions_not_met_at: time, updated_at: time)
    end
    # service generates two audit writes, one for status, one for timestamp
    choice.audits.second_to_last&.update_columns(created_at: time)
    choice.audits.last&.update_columns(created_at: time)
  end

  def confirm_offer_conditions(choice)
    as_provider_user(choice) do
      fast_forward(1..3)
      ConfirmOfferConditions.new(actor: actor, application_choice: choice).save
      choice.update_columns(recruited_at: time, updated_at: time)
    end
    # service generates two audit writes, one for status, one for timestamp
    choice.audits.second_to_last&.update_columns(created_at: time)
    choice.audits.last&.update_columns(created_at: time)
  end

  def add_note(choice)
    previous_updated_at = choice.updated_at

    provider_user = choice.provider.provider_users.first
    provider_user ||= add_provider_user_to_provider(choice.provider)
    as_provider_user(choice) do
      travel_to time + rand(-5..5).days
      FactoryBot.create(
        :note,
        application_choice: choice,
        provider_user: provider_user,
        created_at: time,
        updated_at: time,
      )
    end

    new_updated_at = [choice.reload.notes.map(&:created_at).max, previous_updated_at].max
    choice.update_columns(updated_at: new_updated_at)
    choice.application_form.update_columns(updated_at: new_updated_at)
  end

  def add_provider_user_to_provider(provider)
    provider_user = FactoryBot.create(:provider_user)
    provider.provider_users << provider_user
    provider_user
  end

  def actor
    SupportUser.first_or_initialize
  end

  def provider_user(choice)
    provider_user = choice.provider.provider_users.first
    return provider_user if provider_user.present?

    provider_user = FactoryBot.create :provider_user
    choice.provider.provider_users << provider_user
    provider_user
  end

  def as_provider_user(choice)
    Audited.audit_class.as_user(provider_user(choice)) do
      yield
    end
  end

  def without_slack_message_sending
    RequestStore.store[:disable_slack_messages] = true
    yield
    RequestStore.store[:disable_slack_messages] = false
  end

  def travel_to(time)
    @time = time
  end

  def fast_forward(range)
    @time = time + rand(range).days
    update_new_audits
  end

  def update_new_audits
    @last_audit_id ||= 0
    @application_form.own_and_associated_audits.where('id > ?', @last_audit_id).each do |audit|
      audit.update_columns(created_at: time)
      @last_audit_id = audit.id
    end
  end

  def fill_vacancies(courses)
    courses.each do |course|
      unless course.full?
        course.course_options.update_all(vacancy_status: :no_vacancies)
      end
    end
    courses
  end

  def create_alternative_locations_and_study_mode(choice)
    alternate_study_mode = choice.course_option.full_time? ? :part_time : :full_time
    course_option = CourseOption.find_by(site: choice.site, course: choice.course, study_mode: alternate_study_mode)
    if course_option
      course_option.vacancies!
    else
      choice.course.full_time_or_part_time!
      CourseOption.create!(course: choice.course,
                           site: choice.course_option.site,
                           study_mode: alternate_study_mode,
                           vacancy_status: :vacancies)
    end
    3.times do
      CourseOption.create!(course: choice.course,
                           study_mode: choice.course_option.study_mode,
                           site: FactoryBot.create(:site, provider: choice.provider),
                           vacancy_status: :vacancies)
    end
  end
end
