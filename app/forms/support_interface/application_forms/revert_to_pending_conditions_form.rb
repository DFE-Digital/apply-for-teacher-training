module SupportInterface
  module ApplicationForms
    class RevertToPendingConditionsForm
      include ActiveModel::Model

      attr_accessor :accept_guidance, :audit_comment_ticket

      validates :accept_guidance, :audit_comment_ticket, presence: true
      validates_with ZendeskUrlValidator

      def save(application_choice)
        self.accept_guidance = ActiveModel::Type::Boolean.new.cast(accept_guidance)

        return false unless valid?

        revert_status_to_pending_conditions(application_choice)
      end

    private

      def revert_status_to_pending_conditions(application_choice)
        if application_choice.recruited?
          SupportInterface::RevertRecruitedToPendingConditions.new(
            application_choice:,
            zendesk_ticket: audit_comment_ticket,
          ).save!
        elsif application_choice.conditions_not_met?
          SupportInterface::RevertConditionsNotMetToPendingConditions.new(
            application_choice:,
            zendesk_ticket: audit_comment_ticket,
          ).save!
        elsif application_choice.offer_deferred?
          SupportInterface::RevertOfferDeferredToPendingConditions.new(
            application_choice:,
            zendesk_ticket: audit_comment_ticket,
          ).save!
        end
      end
    end
  end
end
