class SendReferenceConfirmationEmail
  def self.call(application_form:, reference:)
    RefereeMailer.reference_confirmation_email(application_form, reference).deliver

    audit_comment = "Reference confirmation email has been sent to the candidate’s reference: #{reference.name} using #{reference.email_address}."
    application_form.update!(audit_comment: audit_comment)
  end
end
