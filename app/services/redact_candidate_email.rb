class RedactCandidateEmail
  def initialize(candidate, audit_comment:)
    @candidate = candidate
    @audit_comment = build_audit_comment(audit_comment)
  end

  def call
    redacted_email = "redacted.email.address#{@candidate.id}@example.com"

    @candidate.update!(
      email_address: redacted_email,
      audit_comment: @audit_comment,
    )
  end

private

  def build_audit_comment(audit_comment)
    <<~COMMENT
      User email replaced following request to stop automatic email reminders and communications.
      User advised that this will prevent access to their account and may also prevent
      communications from providers they have applied to. Reversion to original email address
      permitted if requested to grant access to account. Extra information: #{audit_comment}
    COMMENT
  end
end
