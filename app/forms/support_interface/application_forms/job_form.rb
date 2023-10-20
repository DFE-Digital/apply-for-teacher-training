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
      end
    end
  end
end
