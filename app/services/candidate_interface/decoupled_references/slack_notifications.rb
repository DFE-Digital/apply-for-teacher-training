module CandidateInterface
  module DecoupledReferences
    module SlackNotifications
      def send_slack_message(application_form, message)
        url = Rails.application.routes.url_helpers.support_interface_application_form_url(application_form)

        SlackNotificationWorker.perform_async(message, url)
      end
    end
  end
end
