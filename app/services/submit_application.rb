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

    CandidateMailer.submit_application_email(application_form).deliver_now
    send_reference_request_email_to_referees(application_form)
  end

private

  def send_reference_request_email_to_referees(application_form)
    application_form.references.each do |reference|
      RefereeMailer.reference_request_email(application_form, reference).deliver_now
    end
  end

  def submit_application
    application_choices.each do |application_choice|
      application_choice.edit_by = ApplicationDates.new(application_form).edit_by
      ApplicationStateChange.new(application_choice).submit!
      StateChangeNotifier.call(:submit_application, application_choice: application_choice)
    end
  end

  def notify_slack
    course_name = @application_choice&.course&.name_and_code
    applicant = @application_choice&.application_form&.first_name
    application_form_id = @application_choice&.application_form&.id
    text = "#{applicant}'s application for #{course_name} has just been submitted"
    url = support_interface_application_form_url(application_form_id) rescue nil
    SlackNotificationWorker.perform_async(text, url)
  end
end
