module CandidateInterface
  module DecoupledReferences
    class RequestReference
      def self.call(reference, flash)
        if reference.not_requested_yet? || reference.cancelled? || reference.cancelled_at_end_of_cycle? || reference.email_bounced?
          RefereeMailer.reference_request_email(reference).deliver_later
          reference.update!(feedback_status: 'feedback_requested', requested_at: Time.zone.now)
          flash[:success] = "Reference request sent to #{reference.name}"
        else
          flash[:warning] = "Reference request already sent to #{reference.name}"
        end
      end
    end
  end
end
