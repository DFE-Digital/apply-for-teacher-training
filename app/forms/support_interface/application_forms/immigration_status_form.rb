module SupportInterface
  module ApplicationForms
    class ImmigrationStatusForm
      include ActiveModel::Model
      include CandidateDetailsHelper

      attr_accessor :immigration_status, :right_to_work_or_study_details, :nationalities, :audit_comment, :application_form

      validates :immigration_status, presence: true
      validates :right_to_work_or_study_details, presence: true, if: :other_immigration_status?
      validates :right_to_work_or_study_details, word_count: { maximum: 7 }
      validates :audit_comment, presence: true
      validates_with SafeChoiceUpdateValidator

      def self.build_from_application(application_form)
        new(
          immigration_status: application_form.immigration_status,
          right_to_work_or_study_details: application_form.right_to_work_or_study_details,
          nationalities: application_form.nationalities,
        )
      end

      def save(application_form)
        @application_form = application_form
        @nationalities = application_form.nationalities

        return false unless valid?

        application_form.update(
          immigration_status:,
          right_to_work_or_study_details: other_immigration_status? ? right_to_work_or_study_details : nil,
          audit_comment:,
        )
      end

      def eu_nationality?
        return false if @nationalities.blank?

        includes_eu_eea_swiss?(nationalities)
      end

      def other_immigration_status?
        immigration_status == 'other'
      end
    end
  end
end
