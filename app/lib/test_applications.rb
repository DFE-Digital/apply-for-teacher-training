class TestApplications
  class NotEnoughCoursesError < RuntimeError; end
  class ZeroCoursesPerApplicationError < RuntimeError; end

  attr_reader :time

  def generate_for_provider(provider:, courses_per_application:, count:)
    1.upto(count).flat_map do
      create_application(
        states: [:awaiting_provider_decision] * courses_per_application,
        courses_to_apply_to: Course.open_on_apply.where(provider: provider),
      )
    end
  end

  def create_application(states:, courses_to_apply_to: nil, apply_again: false)
    candidate = nil

    if apply_again
      raise OnlyOneCourseWhenApplyingAgainError, 'You can only apply to one course when applying again' unless states.one?

      create_application(states: [:rejected])

      candidate = Candidate.last
    else
      travel_to rand(30..60).days.ago
      raise ZeroCoursesPerApplicationError, 'You can\'t have zero courses per application' unless states.any?

      first_name = Faker::Name.first_name
      last_name = Faker::Name.last_name
      candidate = FactoryBot.create(
        :candidate,
        email_address: "#{first_name.downcase}.#{last_name.downcase}@example.com",
        created_at: time,
      )
    end

    courses_to_apply_to ||= Course.joins(:course_options)
      .open_on_apply

    courses_to_apply_to = courses_to_apply_to.sample(states.count)

    # it does not make sense to apply to the same course multiple times
    # in the course of the same application, and it's forbidden in the UI.
    # Throw an exception if we try to do that here.
    if courses_to_apply_to.count < states.count
      raise NotEnoughCoursesError, "Not enough distinct courses to generate a #{states.count}-course application"
    end

    Audited.audit_class.as_user(candidate) do
      @application_form = FactoryBot.create(
        :completed_application_form,
        application_choices_count: 0,
        full_work_history: true,
        volunteering_experiences_count: 1,
        references_count: 2,
        with_gces: true,
        with_degree: true,
        submitted_at: nil,
        candidate: candidate,
        first_name: first_name,
        last_name: last_name,
        created_at: time,
        edit_by: time,
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
        )
      end

      return if states.include? :unsubmitted

      without_slack_message_sending do
        fast_forward(1..2)
        SubmitApplication.new(@application_form).call
        @application_form.update_columns(submitted_at: time, edit_by: time + 7.days)
        return if states.include? :awaiting_references

        @application_form.application_references.each do |reference|
          reference.relationship_correction = ['', Faker::Lorem.sentence].sample
          reference.safeguarding_concerns = ['', Faker::Lorem.sentence].sample
          reference.safeguarding_concerns_status = reference.safeguarding_concerns.blank? ? :no_safeguarding_concerns_to_declare : :has_safeguarding_concerns_to_declare

          reference.update!(feedback: 'You are awesome')

          SubmitReference.new(
            reference: reference,
          ).save!
        end
        return if states.include? :application_complete

        application_choices.map(&:reload)

        states.zip(application_choices).each do |state, application_choice|
          put_application_choice_in_state(application_choice, state)
        end
      end

      application_choices.each do |application_choice|
        rand(0..3).times { add_note(application_choice) }
      end

      application_choices
    end
  end

  def put_application_choice_in_state(choice, state)
    travel_to(choice.application_form.edit_by) if choice.application_form.edit_by > time
    SendApplicationToProvider.new(application_choice: choice).call
    choice.update(sent_to_provider_at: time)
    return if state == :awaiting_provider_decision

    case state
    when :offer
      make_offer(choice)
    when :rejected
      reject_application(choice)
    when :offer_withdrawn
      make_offer(choice)
      withdraw_offer(choice)
    when :declined
      make_offer(choice)
      decline_offer(choice)
    when :accepted
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
    when :enrolled
      make_offer(choice)
      accept_offer(choice)
      confirm_offer_conditions(choice)
      confirm_enrollment(choice)
    when :withdrawn
      withdraw_application(choice)
    end
  end

  def accept_offer(choice)
    fast_forward(1..3)
    AcceptOffer.new(application_choice: choice).save!
    choice.update_columns(accepted_at: time)
  end

  def withdraw_application(choice)
    fast_forward(1..3)
    WithdrawApplication.new(application_choice: choice).save!
    choice.update_columns(withdrawn_at: time)
  end

  def decline_offer(choice)
    fast_forward(1..3)
    DeclineOffer.new(application_choice: choice).save!
    choice.update_columns(declined_at: time)
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
      choice.update_columns(offered_at: time)
    end
  end

  def reject_application(choice)
    as_provider_user(choice) do
      fast_forward(1..3)
      RejectApplication.new(application_choice: choice, rejection_reason: 'Some').save
      choice.update_columns(rejected_at: time)
    end
  end

  def withdraw_offer(choice)
    as_provider_user(choice) do
      fast_forward(1..3)
      WithdrawOffer.new(application_choice: choice, offer_withdrawal_reason: 'Offer withdrawal reason is...').save
      choice.update_columns(withdrawn_at: time)
    end
  end

  def conditions_not_met(choice)
    as_provider_user(choice) do
      fast_forward(1..3)
      ConditionsNotMet.new(application_choice: choice).save
      choice.update_columns(conditions_not_met_at: time)
    end
  end

  def confirm_offer_conditions(choice)
    as_provider_user(choice) do
      fast_forward(1..3)
      ConfirmOfferConditions.new(application_choice: choice).save
      choice.update_columns(recruited_at: time)
    end
  end

  def confirm_enrollment(choice)
    as_provider_user(choice) do
      fast_forward(1..3)
      ConfirmEnrolment.new(application_choice: choice).save
      choice.update_columns(enrolled_at: time)
    end
  end

  def add_note(choice)
    provider_user = choice.provider.provider_users.first
    provider_user ||= add_provider_user_to_provider(choice.provider)
    as_provider_user(choice) do
      travel_to time + rand(-5..5).days
      FactoryBot.create(
        :note,
        application_choice: choice,
        provider_user: provider_user,
        created_at: time,
      )
    end
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
end
