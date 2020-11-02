module CandidateInterface
  class CancelReference
    def self.call(reference)
      new(reference).call
    end

    attr_reader :reference

    def initialize(reference)
      @reference = reference
    end

    def call
      reference.update!(feedback_status: 'cancelled')
      RefereeMailer.reference_cancelled_email(reference).deliver_later
      send_slack_message
    end

  private

    def application_form
      reference.application_form
    end

    def send_slack_message
      message = "Candidate #{application_form.first_name} has cancelled one of their references"
      url = Rails.application.routes.url_helpers.support_interface_application_form_url(application_form)
      SlackNotificationWorker.perform_async(message, url)
    end
  end
end
