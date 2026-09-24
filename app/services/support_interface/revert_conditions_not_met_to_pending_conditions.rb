module SupportInterface
  class RevertConditionsNotMetToPendingConditions
    def initialize(application_choice:, zendesk_ticket:)
      @application_choice = application_choice
      @zendesk_ticket = zendesk_ticket
    end

    def save!
      @application_choice.offer.conditions.each(&:pending!)

      @application_choice.update!(
        status: :pending_conditions,
        conditions_not_met_at: nil,
        audit_comment: "Support request to revert conditions not met application to pending conditions: #{@zendesk_ticket}",
      )
    end
  end
end
