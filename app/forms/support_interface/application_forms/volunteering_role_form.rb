module SupportInterface
  module ApplicationForms
    class VolunteeringRoleForm < Shared::VolunteeringRoleForm
      validates :audit_comment, presence: true
      validates_with ZendeskUrlValidator

      attr_accessor :audit_comment

      def map_attributes
        super.merge(audit_comment: audit_comment)
      end
    end
  end
end
