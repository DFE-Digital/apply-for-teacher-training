module SupportInterface
  class RevertOfferDeferredToPendingConditions
    include SubsequentApplicationDeletable

    def initialize(application_choice:, zendesk_ticket:)
      @application_choice = application_choice
      @zendesk_ticket = zendesk_ticket
    end

    def save!
      @application_choice.offer.conditions.each(&:pending!)

      @application_choice.update!(
        status: :pending_conditions,
        offer_deferred_at: nil,
        status_before_deferral: nil,
        audit_comment: "Support request to revert offer deferred application to pending conditions: #{@zendesk_ticket}",
      )
      delete_subsequent_application_form(@application_choice.application_form)
    end
  end
end
