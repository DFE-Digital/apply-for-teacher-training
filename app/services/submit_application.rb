class SubmitApplication
  attr_reader :application_form, :application_choices

  REFEREE_BOT_EMAIL_ADDRESSES = ['refbot1@example.com', 'refbot2@example.com'].freeze

  def initialize(application_form)
    @application_form = application_form
    @application_choices = application_form.application_choices
  end

  def call
    ActiveRecord::Base.transaction do
      application_form.update!(submitted_at: Time.zone.now)
      submit_application
    end

    CandidateMailer.submit_application_email(application_form).deliver_later
    send_reference_request_email_to_referees(application_form)
    StateChangeNotifier.call(:submit_application, application_form: application_form)
    auto_approve_references_in_sandbox(application_form)
  end

private

  def send_reference_request_email_to_referees(application_form)
    application_form.application_references.includes(:application_form).each do |reference|
      RefereeMailer.reference_request_email(application_form, reference).deliver_later

      reference.update!(feedback_status: 'feedback_requested', requested_at: Time.zone.now)
    end
  end

  def auto_approve_references_in_sandbox(application_form)
    application_form.application_references.includes(:application_form).each do |reference|
      auto_approve_reference(reference) if HostingEnvironment.sandbox_mode? && email_address_is_a_bot?(reference)
    end
  end

  def auto_approve_reference(reference)
    ReceiveReference.new(
      reference: reference,
      feedback: I18n.t('new_referee_request.auto_approve_feedback'),
    ).save!
  end

  def email_address_is_a_bot?(reference)
    REFEREE_BOT_EMAIL_ADDRESSES.include?(reference.email_address)
  end

  def submit_application
    application_choices.each do |application_choice|
      submit_application_choice(application_choice)
    end
  end

  def submit_application_choice(application_choice)
    edit_by_time = time_limit_calculator.call[:time_in_future]
    application_choice.edit_by = edit_by_time
    ApplicationStateChange.new(application_choice).submit!
  end

  def time_limit_calculator
    klass = HostingEnvironment.sandbox_mode? ? SandboxTimeLimitCalculator : TimeLimitCalculator
    klass.new(
      rule: :edit_by,
      effective_date: application_form.submitted_at,
    )
  end
end
