module SupportInterface
  class UndoReferenceRefusal
    def initialize(reference)
      @reference = reference
    end

    def call
      @reference.update!(
        feedback_status: 'feedback_requested',
        feedback_refused_at: nil,
        audit_comment: 'Reversing refusal using the Support interface, so that the referee is able to provide a reference again',
      )
    end
  end
end
