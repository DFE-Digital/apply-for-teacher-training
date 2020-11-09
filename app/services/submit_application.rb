class SubmitApplication
  attr_reader :application_form, :application_choices

  def initialize(application_form)
    @application_form = application_form
    @application_choices = application_form.application_choices
  end

  def call
    application_form.update!(submitted_at: Time.zone.now)

    application_choices.each do |application_choice|
      SendApplicationToProvider.call(application_choice)
    end

    if application_form.apply_2?
      CandidateMailer.application_submitted_apply_again(application_form).deliver_later
    else
      CandidateMailer.application_submitted(application_form).deliver_later
    end

    message = ":rocket: #{application_form.first_name}’s application has been sent to #{application_choices.map(&:provider).map(&:name).to_sentence}"
    url = Rails.application.routes.url_helpers.support_interface_application_form_url(application_form)
    SlackNotificationWorker.perform_async(message, url)
  end
end
