module CandidateInterface
  class SendReferenceReminder
    def self.call(reference, flash)
      new(reference, flash).call
    end

    attr_reader :reference, :flash

    def initialize(reference, flash)
      @reference = reference
      @flash = flash
    end

    def call
      if reference.can_send_reminder?
        RefereeMailer.reference_request_chaser_email(application_form, reference).deliver_later
        reference.update!(reminder_sent_at: Time.zone.now)

        send_slack_message(message)

        flash[:success] = "Reminder sent to #{referee_name}"
      end
    end

  private

    def message
      "Candidate #{application_form.first_name} has sent a reminder to #{referee_first_name}"
    end

    def referee_name
      reference.name
    end

    def referee_first_name
      reference.name.split.first
    end

    def application_form
      reference.application_form
    end

    def send_slack_message(message)
      url = Rails.application.routes.url_helpers.support_interface_application_form_url(application_form)
      SlackNotificationWorker.perform_async(message, url)
    end
  end
end
