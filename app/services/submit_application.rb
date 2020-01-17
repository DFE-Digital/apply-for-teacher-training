class SubmitApplication
  attr_reader :application_form, :application_choices

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
  end

private

  def send_reference_request_email_to_referees(application_form)
    application_form.application_references.includes(:application_form).each do |reference|
      RefereeMailer.reference_request_email(application_form, reference).deliver_later
    end
  end

  def submit_application
    application_choices.each do |application_choice|
      submit_application_choice(application_choice)
    end
  end

  def submit_application_choice(application_choice)
    return send_to_provider_immediately(application_choice) if sandbox?

    edit_by = TimeLimitCalculator.new(
      rule: :edit_by,
      effective_date: application_form.submitted_at,
    ).call.second

    application_choice.edit_by = edit_by
    ApplicationStateChange.new(application_choice).submit!
  end

  def send_to_provider_immediately(application_choice)
    application_choice.edit_by = Time.zone.now
    ApplicationStateChange.new(application_choice).submit!
  end

  def sandbox?
    ENV.fetch('SANDBOX') { 'false' } == 'true'
  end
end
