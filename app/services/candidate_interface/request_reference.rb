module CandidateInterface
  class RequestReference
    def self.call(reference)
      RefereeMailer.reference_request_email(reference.application_form, reference).deliver_later
      reference.update!(feedback_status: 'feedback_requested', requested_at: Time.zone.now)
    end
  end
end
