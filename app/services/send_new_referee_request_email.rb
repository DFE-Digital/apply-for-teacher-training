class SendNewRefereeRequestEmail
  def self.call(application_form:, reference:, reason: :not_responded)
    CandidateMailer.new_referee_request(application_form, reference, reason: reason).deliver

    candidate_email = application_form.candidate.email_address
    audit_comment = I18n.t("new_referee_request.#{reason}.audit_comment", candidate_email: candidate_email)
    application_comment = SupportInterface::ApplicationCommentForm.new(comment: audit_comment)
    application_comment.save(application_form)
  end
end
