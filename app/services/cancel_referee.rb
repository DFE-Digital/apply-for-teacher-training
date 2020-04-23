class CancelReferee
  def call(reference:)
    reference.update!(feedback_status: 'cancelled')
    RefereeMailer.reference_cancelled_email(reference).deliver_later
    send_slack_message(reference, reference.application_form)
  end

private

  def send_slack_message(reference, application_form)
    message = "Candidate #{reference.application_form.first_name} has cancelled one of their references"
    url = Rails.application.routes.url_helpers.support_interface_application_form_url(application_form)

    SlackNotificationWorker.perform_async(message, url)
  end
end
