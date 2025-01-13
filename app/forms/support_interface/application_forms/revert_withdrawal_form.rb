module SupportInterface
  module ApplicationForms
    class RevertWithdrawalForm
      include ActiveModel::Model

      attr_accessor :accept_guidance, :audit_comment_ticket, :application_choice

      validate :valid_service
      validates_with ZendeskUrlValidator
      validates :accept_guidance, presence: true

      def save
        self.accept_guidance = ActiveModel::Type::Boolean.new.cast(accept_guidance)

        validate

        return false if errors.any?

        ActiveRecord::Base.transaction do
          revert_withdrawal_service.withdrawal_reasons.destroy_all
          revert_withdrawal_service.save
        end
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
