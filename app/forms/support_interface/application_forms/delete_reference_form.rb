module SupportInterface
  module ApplicationForms
    class DeleteReferenceForm
      include ActiveModel::Model

      attr_accessor :reference, :accept_guidance, :audit_comment_ticket, :application_form

      validates :accept_guidance, presence: true
      validates :audit_comment_ticket, presence: true
      validates_with ZendeskUrlValidator
      validates_with SafeChoiceUpdateValidator

      def save(actor:, reference:)
        @reference = reference
        @application_form = reference.application_form

        return false unless valid?

        SupportInterface::DeleteReference.new.call!(
          actor:,
          reference:,
          zendesk_url: audit_comment_ticket,
        )
      end
    end
  end
end
