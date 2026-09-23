module SupportInterface
  class RevertRecruitedToPendingConditions
    include SubsequentApplicationDeletable

    def initialize(application_choice:, zendesk_ticket:)
      @application_choice = application_choice
      @zendesk_ticket = zendesk_ticket
    end

    def save!
      @application_choice.offer.conditions.each(&:pending!)

      @application_choice.update!(
        status: :pending_conditions,
        recruited_at: nil,
        audit_comment: "Support request to revert recruited application to pending conditions: #{@zendesk_ticket}",
      )
      delete_subsequent_application_form(@application_choice.application_form)
    end
  end
end
