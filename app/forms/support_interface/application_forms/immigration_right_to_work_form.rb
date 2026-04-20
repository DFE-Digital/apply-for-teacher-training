module SupportInterface
  module ApplicationForms
    class ImmigrationRightToWorkForm
      include ActiveModel::Model
      include ActiveModel::Validations::Callbacks

      attr_accessor :right_to_work_or_study, :right_to_work_or_study_details, :audit_comment

      validates :right_to_work_or_study, presence: true
      validates :audit_comment, presence: true

      def self.build_from_application(application_form)
        new(
          right_to_work_or_study: application_form.right_to_work_or_study,
          right_to_work_or_study_details: application_form.right_to_work_or_study_details,
        )
      end

      def save(application_form)
        return false unless valid?

        update_result = application_form.update(
          right_to_work_or_study:,
          right_to_work_or_study_details: set_right_to_work_or_study_details,
          immigration_status: immigration_status_value(application_form),
          visa_expired_at: right_to_work_or_study? ? application_form.visa_expired_at : nil,
          audit_comment:,
        )
        update_visa_explanation(application_form)

        update_result
      end

    private

      def right_to_work_or_study?
        right_to_work_or_study == 'yes'
      end

      def set_right_to_work_or_study_details
        right_to_work_or_study? ? right_to_work_or_study_details : nil
      end

      def immigration_status_value(application_form)
        right_to_work_or_study? ? application_form.immigration_status : nil
      end

      def update_visa_explanation(application_form)
        if !right_to_work_or_study?
          application_form.application_choices.where.not(visa_explanation: nil).each do |choice|
            choice.update(visa_explanation: nil, visa_explanation_details: nil)
          end
        end
      end
    end
  end
end
