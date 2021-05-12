module SupportInterface
  class RevertRejection
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
        audit_comment: "Support request to revert rejection: #{@zendesk_ticket}",
      )
    end
  end
end
