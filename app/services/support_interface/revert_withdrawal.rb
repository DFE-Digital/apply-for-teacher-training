module SupportInterface
  class RevertWithdrawal
    def initialize(application_choice:, zendesk_ticket:)
      @application_choice = application_choice
      @zendesk_ticket = zendesk_ticket
    end

    def save!
      @application_choice.update!(
        status: :awaiting_provider_decision,
        withdrawn_at: nil,
        withdrawal_feedback: nil,
        audit_comment: "Support request after candidate withdrew their application in error: #{@zendesk_ticket}",
      )
    end
  end
end
