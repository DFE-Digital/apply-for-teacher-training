module RefereeInterface
  class RefuseFeedbackForm
    include ActiveModel::Model

    attr_accessor :choice

    validates :choice, presence: true

    def save(reference)
      return false unless valid?

      reference.feedback_refused!
      send_slack_notification(reference)
      SendNewRefereeRequestEmail.call(reference: reference, reason: :refused)
    end

    def referee_has_confirmed_they_wont_a_reference?
      choice == 'yes'
    end

  private

    def send_slack_notification(reference)
      message = ":sadparrot: A referee declined to give feedback for #{reference.application_form.first_name}’s application"
      url = Rails.application.routes.url_helpers.support_interface_application_form_url(reference.application_form)

      SlackNotificationWorker.perform_async(message, url)
    end
  end
end
