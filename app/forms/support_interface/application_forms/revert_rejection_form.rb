module SupportInterface
  module ApplicationForms
    class RevertRejectionForm
      include ActiveModel::Model

      attr_accessor :accept_guidance, :audit_comment_ticket

      validates :accept_guidance, :audit_comment_ticket, presence: true
      validates :audit_comment_ticket, format: { with: /\A((http|https):\/\/)?(www.)?becomingateacher.zendesk.com\/agent\/tickets\// }

      def save(application_choice)
        self.accept_guidance = ActiveModel::Type::Boolean.new.cast(accept_guidance)

        return false unless valid?

        SupportInterface::RevertRejection.new(
          application_choice: application_choice,
          zendesk_ticket: audit_comment_ticket,
        ).save!
      end
    end
  end
end
