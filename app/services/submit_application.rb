class SubmitApplication
  attr_reader :application_form, :application_choices

  def initialize(application_form)
    @application_form = application_form
    @application_choices = application_form.application_choices
  end

  def call
    ActiveRecord::Base.transaction do
      application_form.update!(support_reference: GenerateSupportRef.call,
                               submitted_at: Time.zone.now)
      submit_application
    end

    CandidateMailer.submit_application_email(application_form).deliver_later
    send_reference_request_email_to_referees(application_form)
    StateChangeNotifier.call(:submit_application, application_form: application_form)
  end

private

  def send_reference_request_email_to_referees(application_form)
    application_form.references.includes(:application_form).each do |reference|
      reference.update_token

      RefereeMailer.reference_request_email(application_form, reference).deliver_later
    end
  end

  def submit_application
    application_choices.each do |application_choice|
      application_choice.edit_by = ApplicationDates.new(application_form).edit_by
      ApplicationStateChange.new(application_choice).submit!
    end
  end
end
