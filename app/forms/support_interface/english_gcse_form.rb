module SupportInterface
  class EnglishGcseForm
    OTHER_UK_QUALIFICATION_TYPE = 'other_uk'.freeze
    NON_UK_QUALIFICATION_TYPE = 'non_uk'.freeze
    MISSING_QUALIFICATION_TYPE = 'missing'.freeze
    include ActiveModel::Model
    include EnglishGcseGradeAttributeBuilder

    attr_accessor :gcse,
                  :application_form,
                  :audit_comment,
                  :qualification_type,
                  :grade,
                  :qualification,
                  :other_grade,
                  :constituent_grades,
                  :english_gcses,
                  :english_single_award,
                  :grade_english_single,
                  :english_double_award,
                  :grade_english_double,
                  :english_language,
                  :grade_english_language,
                  :english_literature,
                  :grade_english_literature,
                  :english_studies_single_award,
                  :grade_english_studies_single,
                  :english_studies_double_award,
                  :grade_english_studies_double,
                  :other_english_gcse,
                  :other_english_gcse_name,
                  :grade_other_english_gcse,
                  :award_year,
                  :other_uk_qualification_type,
                  :non_uk_qualification_type,
                  :enic_reference,
                  :enic_reason,
                  :comparable_uk_qualification,
                  :subject,
                  :not_completed_explanation,
                  :missing_explanation,
                  :institution_country

    attr_writer :currently_completing_qualification

    validates :audit_comment, presence: true
    validates_with ZendeskUrlValidator
    validates_with SafeChoiceUpdateValidator

    validates :grade, presence: true, unless: ->(record) { record.multiple_gcse? || record.missing_qualification? }
    validates :grade, length: { maximum: ApplicationQualification::MAX_QUALIFICATION_GRADE_LENGTH }
    validates :other_grade, presence: true, if: :grade_is_other?
    validate :validate_grade_format, unless: :multiple_gcse?
    validate :validate_grades_format, if: :multiple_gcse?
    validate :gcse_selected, if: :multiple_gcse?
    validates :award_year, presence: true, year: { future: true }, unless: :missing_qualification?
    validates :award_year, o_level_award_year: true, unless: ->(c) { c.errors.attribute_names.include?(:award_year) }

    validates :other_uk_qualification_type, presence: true, if: :other_uk_qualification?
    validates :non_uk_qualification_type, presence: true, if: :non_uk_qualification?
    validates :non_uk_qualification_type, :subject, :qualification_type, length: { maximum: ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH }
    validates :other_uk_qualification_type, length: { maximum: 100 }

    validates :institution_country, presence: true, inclusion: { in: COUNTRIES_AND_TERRITORIES }, if: :non_uk_qualification?

    validates :not_completed_explanation, presence: true, if: ->(record) { record.missing_qualification? && record.currently_completing_qualification? }
    validates :not_completed_explanation, length: { maximum: 256 }
    validate :validates_currently_completing_qualification, if: :missing_qualification?

    def self.build_from_qualification(qualification)
      new(
        build_params_from(qualification).merge(
          application_form: qualification.application_form,
          qualification_type: qualification.qualification_type,
          subject: qualification.subject,
          other_uk_qualification_type: qualification.other_uk_qualification_type,
          non_uk_qualification_type: qualification.non_uk_qualification_type,
          enic_reference: qualification.enic_reference,
          enic_reason: qualification.enic_reason,
          comparable_uk_qualification: qualification.comparable_uk_qualification,
          currently_completing_qualification: qualification.currently_completing_qualification,
          not_completed_explanation: qualification.not_completed_explanation,
          missing_explanation: qualification.missing_explanation,
          institution_country: qualification.institution_country,
        ),
      )
    end

    def assign_values(params)
      @qualification_type = qualification.qualification_type = params[:qualification_type]

      super

      @award_year = params[:award_year]
      @other_uk_qualification_type = params[:other_uk_qualification_type]
      @non_uk_qualification_type = params[:non_uk_qualification_type]
      @enic_reference = params[:enic_reference]
      @enic_reason = params[:enic_reason]
      @comparable_uk_qualification = params[:comparable_uk_qualification]
      @currently_completing_qualification = params[:currently_completing_qualification]
      @not_completed_explanation = params[:not_completed_explanation]
      @missing_explanation = params[:missing_explanation]
      @institution_country = params[:institution_country]
      @audit_comment = params[:audit_comment]

      reset_other_uk_qualification_type
      reset_non_uk_qualification_type
      reset_currently_completing_qualification
    end

    def save
      return false unless valid?

      update_gcse.tap do
        reset_missing_and_not_completed_explanations!(qualification)
      end
    end

    def update_gcse
      if multiple_gcse?
        qualification.update(
          constituent_grades: build_grades_json,
          award_year:,
          qualification_type:,
          grade: nil,
          other_uk_qualification_type: nil,
          non_uk_qualification_type: nil,
          enic_reference: nil,
          enic_reason: nil,
          comparable_uk_qualification: nil,
          currently_completing_qualification: nil,
          not_completed_explanation: nil,
          missing_explanation: nil,
        )
      elsif missing_qualification?
        qualification.update!(
          qualification_type:,
          currently_completing_qualification:,
          not_completed_explanation:,
          missing_explanation:,
          grade: nil,
          constituent_grades: nil,
          award_year: nil,
          institution_name: nil,
          institution_country: nil,
          other_uk_qualification_type: nil,
          non_uk_qualification_type: nil,
          enic_reference: nil,
          enic_reason: nil,
          comparable_uk_qualification: nil,
        )
      else
        qualification.update(
          grade:,
          award_year:,
          qualification_type:,
          other_uk_qualification_type:,
          non_uk_qualification_type:,
          enic_reference:,
          enic_reason:,
          comparable_uk_qualification:,
          institution_country:,
          constituent_grades: nil,
          currently_completing_qualification: nil,
          not_completed_explanation: nil,
          missing_explanation: nil,
        )
      end
    end

    def missing_qualification?
      qualification_type == MISSING_QUALIFICATION_TYPE
    end

    def currently_completing_qualification?
      currently_completing_qualification.present?
    end

    def currently_completing_qualification
      ActiveModel::Type::Boolean.new.cast(@currently_completing_qualification)
    end

  private

    def non_uk_qualification?
      qualification_type == NON_UK_QUALIFICATION_TYPE
    end

    def other_uk_qualification?
      qualification_type == OTHER_UK_QUALIFICATION_TYPE
    end

    def reset_other_uk_qualification_type
      if !other_uk_qualification?
        @other_uk_qualification_type = nil
      end
    end

    def reset_non_uk_qualification_type
      if !non_uk_qualification?
        @non_uk_qualification_type = nil
        @enic_reference = nil
        @comparable_uk_qualification = nil
        @institution_country = nil
      end
    end

    def reset_currently_completing_qualification
      return unless missing_qualification?

      if currently_completing_qualification?
        @missing_explanation = nil
      else
        @not_completed_explanation = nil
      end
    end

    def validates_currently_completing_qualification
      unless currently_completing_qualification.in? [true, false]
        errors.add(
          :currently_completing_qualification,
          message: 'Choose an option if candidate is currently studying for a GCSE',
        )
      end
    end
  end
end
