class SendChaseEmailToCandidate
  def self.call(application_form:)
    CandidateMailer.chase_candidate_decision(application_form).deliver
    ChaserSent.create!(chased: application_form, chaser_type: :candidate_decision_request)

    audit_comment =
      'Chase email has been sent to candidate because ' +
      'the application form is close to its DBD date.'
    application_form.update!(audit_comment: audit_comment)
  end
end
