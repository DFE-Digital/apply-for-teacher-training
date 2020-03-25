class SendChaseEmailToCandidate
  def self.call(application_form:)
    CandidateMailer.chase_candidate_decision(application_form).deliver_later
    ChaserSent.create!(chased: application_form, chaser_type: :candidate_decision_request)
  end
end
