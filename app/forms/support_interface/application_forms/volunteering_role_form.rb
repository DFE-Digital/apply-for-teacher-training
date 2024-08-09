module SupportInterface
  module ApplicationForms
    class VolunteeringRoleForm < Shared::VolunteeringRoleForm
      validates :audit_comment, presence: true
      validates_with ZendeskUrlValidator

      attr_accessor :audit_comment

      def map_attributes
        super.merge(audit_comment: audit_comment)
      end

      def update(application_form)
        super

        ApplicationVolunteeringExperience.where(
          application_form_id: application_form.id,
          experienceable_id: [application_form.application_choices.pluck(:id)],
          experienceable_type: 'ApplicationChoice',
        ).each do |volunteering_experience|
          # Update 1 by 1 because of the audit comment AR column, update_all does not have it
          volunteering_experience.update!(map_attributes)
        end
      end
    end
  end
end
