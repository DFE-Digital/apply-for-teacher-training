module SupportInterface
  module ApplicationForms
    class EditOtherQualificationForm
      include ActiveModel::Model

      A_LEVEL_TYPE = 'A level'.freeze
      AS_LEVEL_TYPE = 'AS level'.freeze
      GCSE_TYPE = 'GCSE'.freeze
      OTHER_TYPE = 'Other'.freeze
      NON_UK_TYPE = 'non_uk'.freeze
      ALL_VALID_TYPES = [A_LEVEL_TYPE, AS_LEVEL_TYPE, GCSE_TYPE, OTHER_TYPE, NON_UK_TYPE].freeze

      attr_reader :qualification
      attr_accessor :qualification_type, :subject, :grade, :award_year, :audit_comment

      validates :subject, :grade, presence: true
      validates :award_year, presence: true, year: { future: true }
      validates :subject, :grade, length: { maximum: 255 }
      validates :audit_comment, presence: true
      validates_with ZendeskUrlValidator
      validate :grade_format_is_valid

      delegate :application_form, to: :qualification

      def initialize(qualification)
        @qualification = qualification

        super(
          qualification_type: @qualification.qualification_type,
          subject: @qualification.subject,
          grade: @qualification.grade,
          award_year: @qualification.award_year
        )
      end

      def assign_attributes_for_qualification(params)
        self.qualification_type = params[:qualification_type]
        attribute_keys = %w[subject grade award_year]
        attribute_data = attribute_keys.index_with { |key| params[key] }
        assign_attributes(attribute_data)
      end

      def save!
        @qualification.update!(
          qualification_type:,
          subject:,
          grade:,
          award_year:,
          audit_comment:,
          other_uk_qualification_type: nil,
        )
      end

    private

      def grade_format_is_valid
        errors.add(:grade, :invalid) unless grade.in?(A_LEVEL_GRADES) || grade.in?(AS_LEVEL_GRADES) || grade.in?(ALL_GCSE_GRADES)
      end
    end
  end
end
