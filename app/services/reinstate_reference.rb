class ReinstateReference
  attr_reader :reference

  def initialize(reference, audit_comment:)
    @reference = reference
    @audit_comment = audit_comment
  end

  def call
    @reference.update!(
      feedback_status: :not_requested_yet,
      cancelled_at: nil,
      audit_comment: @audit_comment,
    )

    RequestReference.new(reference:).send_request
  end
end
