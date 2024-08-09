module SupportInterface
  module ApplicationForms
    class JobForm < Shared::JobForm
      validates :audit_comment, presence: true
      validates_with ZendeskUrlValidator

      attr_accessor :audit_comment

      def update(job)
        return false unless valid?

        job.update!(
          role:,
          organisation:,
          commitment:,
          start_date:,
          end_date: not_currently_employed_in_this_role? ? end_date : nil,
          start_date_unknown:,
          end_date_unknown:,
          currently_working:,
          relevant_skills:,
          details: set_details_field,
          audit_comment:,
        )

        application_form = job.application_form
        ApplicationWorkExperience.where(
          application_form_id: application_form.id,
          experienceable_id: [application_form.application_choices.pluck(:id)],
          experienceable_type: 'ApplicationChoice',
        ).each do |work_experience|
          # Update 1 by 1 because of the audit comment AR column, update_all does not have it
          work_experience.update!(
            role:,
            organisation:,
            commitment:,
            start_date:,
            end_date: not_currently_employed_in_this_role? ? end_date : nil,
            start_date_unknown:,
            end_date_unknown:,
            currently_working:,
            relevant_skills:,
            details: set_details_field,
            audit_comment:,
          )
        end
      end
    end
  end
end
