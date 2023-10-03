module RefereeInterface
  class ConfirmRefuseFeedbackForm
    include ActiveModel::Model

    def save(reference)
      ApplicationForm.with_unsafe_application_choice_touches do
        reference.update!(feedback_status: :feedback_refused, feedback_refused_at: Time.zone.now)
      end
      send_slack_notification(reference)
      SendNewRefereeRequestEmail.call(reference:, reason: :refused)
    end

  private

    def send_slack_notification(reference)
      message = ":sadparrot: A referee declined to give feedback for #{reference.application_form.first_name}’s application"
      url = Rails.application.routes.url_helpers.support_interface_application_form_url(reference.application_form)

      SlackNotificationWorker.perform_async(message, url)
    end
  end
end
