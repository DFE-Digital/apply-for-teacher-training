class SendChaseEmailToRefereeAndCandidate
  def self.call(application_form:, reference:)
    RefereeMailer.reference_request_chaser_email(application_form, reference).deliver
    ChaserSent.create!(chased: reference, chaser_type: :reference_request)

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
