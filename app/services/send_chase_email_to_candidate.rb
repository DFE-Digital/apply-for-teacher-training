class SendChaseEmailToCandidate
  def self.call(application_form:)
    CandidateMailer.chase_candidate_decision(application_form).deliver
    ChaserSent.create!(chased: application_form, chaser_type: :candidate_decision_request)

    audit_comment =
      "Chase emails have been sent to candidate (#{application_form.candidate.email_address}) because " +
      'the application form is close to its DBD date.'
    application_form.update!(audit_comment: audit_comment)
  end
end
