module CandidateInterface
  class SendReferenceReminder
    def self.call(reference, flash)
      new(reference, flash).call
    end

    attr_reader :reference, :flash
    delegate :application_form, to: :reference

    def initialize(reference, flash)
      @reference = reference
      @flash = flash
    end

    def call
      policy = ReferenceActionsPolicy.new(reference)

      if policy.can_send_reminder?
        RefereeMailer.reference_request_chaser_email(application_form, reference).deliver_later

        ApplicationForm.with_unsafe_application_choice_touches do
          reference.update!(reminder_sent_at: Time.zone.now)
        end

        flash[:success] = "Reminder sent to #{referee_name}"
      end
    end

  private

    def referee_name
      reference.name
    end
  end
end
