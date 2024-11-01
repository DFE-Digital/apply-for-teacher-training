module SupportInterface
  module ApplicationForms
    class EditOtherQualificationForm
      include ActiveModel::Model
      include ActiveModel::Validations::Callbacks

      A_LEVEL_TYPE = 'A level'.freeze
      AS_LEVEL_TYPE = 'AS level'.freeze
      GCSE_TYPE = 'GCSE'.freeze
      OTHER_TYPE = 'Other'.freeze
      NON_UK_TYPE = 'non_uk'.freeze
      ALL_VALID_TYPES = [A_LEVEL_TYPE, AS_LEVEL_TYPE, GCSE_TYPE, OTHER_TYPE, NON_UK_TYPE].freeze

      attr_reader :qualification
      attr_accessor :qualification_type, :subject, :grade, :award_year, :other_uk_qualification_type, :non_uk_qualification_type, :audit_comment

      before_validation :sanitize_grade_where_required

      validates :subject, :audit_comment, presence: true
      validates :grade, presence: true, if: -> { should_validate_grade? }
      validates :other_uk_qualification_type, presence: true, if: -> { other_uk_qualification_type? }
      validates :non_uk_qualification_type, presence: true, if: -> { non_uk_qualification_type? }
      validates :award_year, presence: true, year: { future: true }
      validates :subject, :grade, length: { maximum: 255 }
      validates :other_uk_qualification_type, length: { maximum: 100 }
      validates_with ZendeskUrlValidator
      validates_with SafeChoiceUpdateValidator

      delegate :application_form, to: :qualification

      def initialize(qualification)
        @qualification = qualification

        super(
          qualification_type: @qualification.qualification_type,
          subject: @qualification.subject,
          grade: @qualification.grade,
          award_year: @qualification.award_year,
          other_uk_qualification_type: @qualification.other_uk_qualification_type,
          non_uk_qualification_type: @qualification.non_uk_qualification_type
        )
      end

      def assign_attributes_for_qualification(params)
        self.qualification_type = params[:qualification_type]

        symbolized_params = params.transform_keys(&:to_sym)

        attribute_keys = %i[subject grade award_year]
        attribute_data = attribute_keys.index_with { |key| symbolized_params[key] }

        assign_attributes(attribute_data)

        self.other_uk_qualification_type = if qualification_type == OTHER_TYPE
                                             symbolized_params[:other_uk_qualification_type]
                                           end

        self.non_uk_qualification_type = if qualification_type == NON_UK_TYPE
                                           symbolized_params[:non_uk_qualification_type]
                                         end
      end

      def save!
        @qualification.update!(
          qualification_type:,
          subject:,
          grade:,
          award_year:,
          audit_comment:,
          other_uk_qualification_type:,
          non_uk_qualification_type:,
        )
      end

    private

      def should_validate_grade?
        [NON_UK_TYPE, OTHER_TYPE].exclude?(qualification_type)
      end

      def sanitize_grade_where_required
        if qualification_needs_grade_sanitized? && grade
          self.grade = grade.delete(' ').upcase
        end
      end

      def qualification_needs_grade_sanitized?
        [A_LEVEL_TYPE, AS_LEVEL_TYPE, GCSE_TYPE].include?(qualification_type)
      end

      def other_uk_qualification_type?
        qualification_type == OTHER_TYPE
      end

      def non_uk_qualification_type?
        qualification_type == NON_UK_TYPE
      end
    end
  end
end
