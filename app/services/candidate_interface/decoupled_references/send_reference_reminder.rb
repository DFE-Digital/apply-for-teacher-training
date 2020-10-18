module CandidateInterface
  module DecoupledReferences
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
          RefereeMailer.reference_request_chaser_email(reference.application_form, reference).deliver_later
          reference.update!(reminder_sent_at: Time.zone.now)
          flash[:success] = "Reminder sent to #{reference.name}"
        end
      end
    end
  end
end
