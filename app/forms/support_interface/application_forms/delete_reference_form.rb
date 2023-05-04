module SupportInterface
  module ApplicationForms
    class DeleteReferenceForm
      include ActiveModel::Model

      attr_accessor :reference, :accept_guidance, :audit_comment_ticket

      validates :accept_guidance, presence: true
      validates :audit_comment_ticket, presence: true
      validates_with ZendeskUrlValidator

      def save(actor:, reference:)
        @reference = reference

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
