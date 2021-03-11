class TestApplications
  class NotEnoughCoursesError < RuntimeError; end
  class ZeroCoursesPerApplicationError < RuntimeError; end

  attr_reader :time

  def generate_for_provider(provider:, courses_per_application:, count:, for_ratified_courses: false)
    courses_to_apply_to = if for_ratified_courses
                            GetCoursesRatifiedByProvider.call(provider: provider)
                          else
                            Course.current_cycle.includes(:course_options)
                              .joins(:course_options).distinct.open_on_apply
                              .where(provider: provider)
                          end
    1.upto(count).flat_map do
      create_application(
        recruitment_cycle_year: RecruitmentCycle.current_year,
        states: [:awaiting_provider_decision] * courses_per_application,
        courses_to_apply_to: courses_to_apply_to,
      )
    end
  end

  def create_application(recruitment_cycle_year:, states:, courses_to_apply_to:, apply_again: false, course_full: false, candidate: nil, decline_by_default_at: 3.days.from_now)
    initialize_time(recruitment_cycle_year)

    if apply_again
      raise OnlyOneCourseWhenApplyingAgainError, 'You can only apply to one course when applying again' unless states.one?

      create_application(recruitment_cycle_year: recruitment_cycle_year, states: [:rejected], courses_to_apply_to: courses_to_apply_to)

      candidate = candidate.presence || Candidate.last
      first_name = candidate.current_application.first_name
      last_name = candidate.current_application.last_name
    else
      raise ZeroCoursesPerApplicationError, 'You cannot have zero courses per application' unless states.any?

      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      candidate = candidate.presence || FactoryBot.create(
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
                   with_safeguarding_issues_never_asked
                   minimum_info]].sample
      traits << :with_equality_and_diversity_data if rand < 0.55

      simulate_signin(candidate)

      @application_form = FactoryBot.create(
        :completed_application_form,
        *traits,
        :with_degree,
        :with_gcses,
        application_choices_count: 0,
        full_work_history: true,
        volunteering_experiences_count: 1,
        submitted_at: nil,
        candidate: candidate,
        first_name: first_name,
        last_name: last_name,
        created_at: time,
        updated_at: time,
        recruitment_cycle_year: recruitment_cycle_year,
        phase: apply_again ? 'apply_2' : 'apply_1',
        work_history_completed: false,
      )

      @application_form.application_work_experiences.each { |experience| experience.update!(created_at: time) }
      @application_form.application_volunteering_experiences.each { |experience| experience.update!(created_at: time) }
      @application_form.application_work_history_breaks.each { |experience| experience.update!(created_at: time) }

      # One reference that will never be requested
      @application_form.application_references << FactoryBot.build(:reference, :not_requested_yet)

      # 4 will be requested
      @application_form.application_references << FactoryBot.build_list(:reference,
                                                                        4,
                                                                        :feedback_requested,
                                                                        created_at: time,
                                                                        updated_at: time)

      fast_forward

      application_choices = courses_to_apply_to.map do |course|
        FactoryBot.create(
          :application_choice,
          status: 'unsubmitted',
          course_option: course.course_options.first,
          application_form: @application_form,
          decline_by_default_at: decline_by_default_at,
          created_at: time,
          updated_at: time,
        )
      end

      if states == [:cancelled]
        # The cancelled state doesn't exist anymore in the current system,
        # so we have to set this manually.
        @application_form.application_choices.each do |application_choice|
          application_choice.update!(
            status: 'cancelled',
          )
        end

        @application_form.application_references.feedback_requested.each do |reference|
          CancelReferee.new.call(reference: reference)
        end

        return application_choices
      end

      if states.include?(:unsubmitted)
        return application_choices
      end

      @application_form.update!(work_history_completed: true)
      fast_forward

      # The first reference is declined by the referee
      @application_form.application_references.feedback_requested.first.update!(feedback_status: 'feedback_refused')

      # The 2 other of the outstanding references come in. However, only the
      # first two are actually submitted, the last one is automatically cancelled.
      @application_form.application_references.feedback_requested.each do |reference|
        submit_reference!(reference.reload)
        fast_forward
      end

      if states.include?(:unsubmitted_with_completed_references)
        return application_choices
      end

      StateChangeNotifier.disable_notifications do
        fast_forward

        SubmitApplication.new(@application_form).call

        @application_form.application_choices.each do |choice|
          choice.update_columns(
            sent_to_provider_at: time,
            reject_by_default_at: time + rand(3..30).days,
            updated_at: time,
          )
          choice.audits.last&.update_columns(created_at: time)
        end

        @application_form.update_columns(submitted_at: time, updated_at: time)

        states.zip(application_choices).each do |state, application_choice|
          maybe_add_note(application_choice.reload)
          put_application_choice_in_state(application_choice.reload, state)
          maybe_add_note(application_choice.reload)
        end

        FactoryBot.create(:ucas_match, application_form: @application_form) if rand < 0.5
      end

      application_choices
    end
  end

  def submit_reference!(reference)
    return unless reference.feedback_requested?

    reference.update!(
      relationship_correction: ['', Faker::Lorem.sentence].sample,
      safeguarding_concerns: ['', Faker::Lorem.sentence].sample,
      safeguarding_concerns_status: reference.safeguarding_concerns.blank? ? :no_safeguarding_concerns_to_declare : :has_safeguarding_concerns_to_declare,
      feedback: 'You are awesome',
    )

    SubmitReference.new(
      reference: reference,
    ).save!
  end

  def put_application_choice_in_state(choice, state)
    choice.update_columns(updated_at: time)
    choice.audits.last&.update_columns(created_at: time)

    return if state == :awaiting_provider_decision

    simulate_signin(choice.application_form.candidate)

    case state
    when :interviewing
      schedule_interview(choice)
    when :offer
      make_offer(choice)
    when :offer_changed
      make_offer(choice)
      change_offer(choice)
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

  def schedule_interview(choice)
    as_provider_user(choice) do
      fast_forward
      CreateInterview.new(
        actor: actor,
        application_choice: choice,
        provider: choice.course_option.provider,
        date_and_time: 7.business_days.from_now,
        location: Faker::Address.full_address,
        additional_details: [nil, nil, 'Use staff entrance', 'Ask for John at the reception'].sample,
      ).save!
      choice.update_columns(updated_at: time)
    end
    choice.audits.last&.update_columns(created_at: time)
  end

  def accept_offer(choice)
    fast_forward
    AcceptOffer.new(application_choice: choice).save!
    choice.update_columns(accepted_at: time, updated_at: time)
    # accept generates two audit writes (minimum), one for status, one for timestamp
    choice.audits.second_to_last&.update_columns(created_at: time)
    choice.audits.last&.update_columns(created_at: time)
  end

  def withdraw_application(choice)
    fast_forward
    WithdrawApplication.new(application_choice: choice).save!
    choice.update_columns(withdrawn_at: time, updated_at: time)
    # service generates two audit writes, one for status, one for timestamp
    choice.audits.second_to_last&.update_columns(created_at: time)
    choice.audits.last&.update_columns(created_at: time)
  end

  def decline_offer(choice)
    fast_forward
    DeclineOffer.new(application_choice: choice).save!
    choice.update_columns(declined_at: time, updated_at: time)
    choice.audits.last&.update_columns(created_at: time)
    # service generates two audit writes, one for status, one for timestamp
    choice.audits.second_to_last&.update_columns(created_at: time)
    choice.audits.last&.update_columns(created_at: time)
  end

  def make_offer(choice, conditions: ['Complete DBS'])
    as_provider_user(choice) do
      fast_forward
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

  def change_offer(choice, conditions: ['Complete DBS'])
    as_provider_user(choice) do
      fast_forward
      year = choice.offered_course.recruitment_cycle_year
      new_course = choice.offered_course.provider.courses
                         .in_cycle(year).with_course_options.sample
      ChangeAnOffer.new(
        actor: actor,
        application_choice: choice,
        course_option: new_course.course_options.first,
        offer_conditions: conditions,
      ).save
      choice.update_columns(offer_changed_at: time, updated_at: time)
    end
    choice.audits.last&.update_columns(created_at: time)
  end

  def reject_application(choice)
    as_provider_user(choice) do
      fast_forward
      RejectApplication.new(
        actor: actor,
        application_choice: choice,
        rejection_reason: Faker::Lorem.paragraph_by_chars(number: 200),
        structured_rejection_reasons: {
          performance_at_interview_y_n: 'Yes',
          performance_at_interview_what_to_improve: 'We felt that pyjamas were a little too casual',
          qualifications_y_n: 'Yes',
          qualifications_which_qualifications: %w[no_maths_gcse no_degree other],
          qualifications_other_details: 'Cycling proficiency badge',
          quality_of_application_y_n: 'Yes',
          quality_of_application_which_parts_needed_improvement: %w[subject_knowledge other],
          quality_of_application_other_details: 'Too many emojis',
        },
      ).save
      choice.update_columns(rejected_at: time, updated_at: time)
    end
    # service generates two audit writes, one for status, one for timestamp
    choice.audits.second_to_last&.update_columns(created_at: time)
    choice.audits.last&.update_columns(created_at: time)
  end

  def withdraw_offer(choice)
    as_provider_user(choice) do
      fast_forward
      WithdrawOffer.new(actor: actor, application_choice: choice, offer_withdrawal_reason: 'Offer withdrawal reason is...').save
      choice.update_columns(offer_withdrawn_at: time, updated_at: time)
    end
    choice.audits.last&.update_columns(created_at: time)
  end

  def defer_offer(choice)
    as_provider_user(choice) do
      fast_forward
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
      fast_forward
      ConditionsNotMet.new(actor: actor, application_choice: choice).save
      choice.update_columns(conditions_not_met_at: time, updated_at: time)
    end
    # service generates two audit writes, one for status, one for timestamp
    choice.audits.second_to_last&.update_columns(created_at: time)
    choice.audits.last&.update_columns(created_at: time)
  end

  def confirm_offer_conditions(choice)
    as_provider_user(choice) do
      fast_forward
      ConfirmOfferConditions.new(actor: actor, application_choice: choice).save
      choice.update_columns(recruited_at: time, updated_at: time)
      # service generates two audit writes, one for status, one for timestamp
      choice.audits.second_to_last&.update_columns(created_at: time)
      choice.audits.last&.update_columns(created_at: time)
    end
  end

  def maybe_add_note(choice)
    return unless rand > 0.3

    previous_updated_at = choice.updated_at

    provider_user = choice.provider.provider_users.first
    provider_user ||= add_provider_user_to_provider(choice.provider)
    as_provider_user(choice) do
      fast_forward
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

  def initialize_time(recruitment_cycle_year)
    in_current_cycle = recruitment_cycle_year == RecruitmentCycle.current_year
    if in_current_cycle
      earliest_date = 20.days.ago.to_date
      latest_date = Time.zone.now.to_date
    else
      earliest_date = EndOfCycleTimetable::CYCLE_DATES[recruitment_cycle_year][:apply_reopens]
      latest_date = EndOfCycleTimetable::CYCLE_DATES[recruitment_cycle_year + 1][:apply_1_deadline]
    end

    @time = rand(earliest_date..latest_date)
    @time_budget = [30, (latest_date.to_date - @time.to_date).to_i].min
  end

  def fast_forward
    return unless @time_budget.positive?

    # We want to spread out actions that happen on an application over time. This ensures we don't use up
    # the entire time budget in one go, and that we have a good chance of jumping forward a bit
    time_to_jump = [rand(0..2), rand(1..@time_budget)].min

    @time_budget -= time_to_jump
    @time = time + time_to_jump.days
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

  def simulate_signin(candidate)
    rand(1..2).times do
      FactoryBot.create(
        :authentication_token,
        user: candidate,
        created_at: time,
      )
    end
  end
end
