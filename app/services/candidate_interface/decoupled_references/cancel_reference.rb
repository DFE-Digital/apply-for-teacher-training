module CandidateInterface
  module DecoupledReferences
    class CancelReference
      include SlackNotifications

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
        send_slack_message(application_form, message)
      end

    private

      def message
        "Candidate #{application_form.first_name} has cancelled one of their references"
      end

      def application_form
        reference.application_form
      end
    end
  end
end
