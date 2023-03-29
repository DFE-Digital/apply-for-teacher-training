module SupportInterface
  module ApplicationForms
    class EditOtherQualificationGradeForm
      include ActiveModel::Model

      attr_reader :qualification
      attr_accessor :grade, :audit_comment

      validates :grade, presence: true
      validates :audit_comment, presence: true
      validates_with ZendeskUrlValidator
      validate :grade_format_is_valid

      delegate :application_form, :subject, to: :qualification

      def initialize(qualification)
        @qualification = qualification

        super(
          grade: @qualification.grade
        )
      end

      def save!
        @qualification.update!(
          grade:,
          audit_comment:,
        )
      end

    private

      def grade_format_is_valid
        errors.add(:grade, :invalid) unless grade.in?(A_LEVEL_GRADES) || grade.in?(AS_LEVEL_GRADES) || grade.in?(ALL_GCSE_GRADES)
      end
    end
  end
end
