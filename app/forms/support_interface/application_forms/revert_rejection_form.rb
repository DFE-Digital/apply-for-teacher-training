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

        # TODO: Call new service to update the application state
      end
    end
  end
end
