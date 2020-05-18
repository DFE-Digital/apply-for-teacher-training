class SendReferenceChaseEmailToRefereeAndCandidate
  def self.call(application_form:, reference:)
    RefereeMailer.reference_request_chaser_email(application_form, reference).deliver_later
    CandidateMailer.chase_reference(reference).deliver_later
    ChaserSent.create!(chased: reference, chaser_type: :reference_request)
  end
end
