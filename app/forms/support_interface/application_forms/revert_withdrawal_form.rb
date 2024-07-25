module SupportInterface
  module ApplicationForms
    class RevertWithdrawalForm
      include ActiveModel::Model

      attr_accessor :accept_guidance, :audit_comment_ticket, :application_choice

      validates :accept_guidance, presence: true
      validate :valid_service
      validates_with ZendeskUrlValidator

      def save
        self.accept_guidance = ActiveModel::Type::Boolean.new.cast(accept_guidance)

        validate

        return false if errors.any?

        revert_withdrawal_service.save
      end

    private

      def valid_service
        revert_withdrawal_service.valid? || errors.merge!(revert_withdrawal_service.errors)
      end

      def revert_withdrawal_service
        @service ||= SupportInterface::RevertWithdrawal.new(
          application_choice:,
          zendesk_ticket: audit_comment_ticket,
        )
      end
    end
  end
end
