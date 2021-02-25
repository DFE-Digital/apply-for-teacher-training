class ReinstateReference
  def self.call(reference)
    raise unless ReferenceActionsPolicy.new(reference).reinstatable?

    reference.update!(
      feedback_status: 'not_requested_yet',
      feedback_refused_at: nil,
      cancelled_at: nil,
      audit_comment: 'Rolling back to reinstate the reference',
    )

    RequestReference.new.call(reference)
  end
end
