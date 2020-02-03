class SendChaseEmailToRefereeAndCandidate
  def self.call(application_form:, reference:)
    reference.update! feedback_status: 'feedback_requested'
    RefereeMailer.reference_request_chaser_email(application_form, reference).deliver
    CandidateMailer.reference_chaser_email(application_form, reference).deliver

    audit_comment = I18n.t(
      'application_form.referees.audit_comment',
      referee_email: reference.email_address,
      candidate_email: application_form.candidate.email_address,
    )

    application_comment = SupportInterface::ApplicationCommentForm.new(comment: audit_comment)
    application_comment.save(application_form)
  end
end
