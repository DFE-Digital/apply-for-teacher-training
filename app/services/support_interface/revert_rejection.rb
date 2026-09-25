module SupportInterface
  class RevertRejection
    include SubsequentApplicationDeletable

    def initialize(application_choice:, zendesk_ticket:)
      @application_choice = application_choice
      @zendesk_ticket = zendesk_ticket
    end

    def save!
      @application_choice.update!(
        status: :awaiting_provider_decision,
        rejected_at: nil,
        structured_rejection_reasons: nil,
        rejection_reason: nil,
        rejection_reasons_type: nil,
        audit_comment: "Support request to revert rejection: #{@zendesk_ticket}",
      )
      delete_subsequent_application_form(@application_choice.application_form)
    end
  end
end
