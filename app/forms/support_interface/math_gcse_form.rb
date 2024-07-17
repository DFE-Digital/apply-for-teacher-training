module SupportInterface
  class MathGcseForm
    GCSE = 'gcse'.freeze
    OTHER_UK_QUALIFICATION_TYPE = 'other_uk'.freeze
    NON_UK_QUALIFICATION_TYPE = 'non_uk'.freeze
    MISSING_QUALIFICATION_TYPE = 'missing'.freeze
    include ActiveModel::Model
    attr_accessor :qualification,
                  :application_form,
                  :qualification_type,
                  :subject,
                  :other_uk_qualification_type,
                  :non_uk_qualification_type,
                  :enic_reference,
                  :comparable_uk_qualification,
                  :not_completed_explanation,
                  :missing_explanation,
                  :institution_country,
                  :grade,
                  :award_year,
                  :audit_comment,
                  :enic_reason

    attr_writer :currently_completing_qualification

    validates :audit_comment, presence: true
    validates_with ZendeskUrlValidator

    validates :grade, presence: true, unless: :missing_qualification?
    validates :grade, length: { maximum: ApplicationQualification::MAX_QUALIFICATION_GRADE_LENGTH }
    validates :award_year, presence: true, year: { future: true }, unless: :missing_qualification?
    validates :award_year, o_level_award_year: true, unless: ->(c) { c.errors.attribute_names.include?(:award_year) }

    validates :other_uk_qualification_type, presence: true, if: :other_uk_qualification?
    validates :non_uk_qualification_type, presence: true, if: :non_uk_qualification?
    validates :non_uk_qualification_type, :subject, :qualification_type, length: { maximum: ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH }
    validates :other_uk_qualification_type, length: { maximum: 100 }

    validates :institution_country, presence: true, inclusion: { in: COUNTRIES_AND_TERRITORIES }, if: :non_uk_qualification?

    validates :not_completed_explanation, presence: true, if: ->(record) { record.missing_qualification? && record.currently_completing_qualification? }
    validates :not_completed_explanation, word_count: { maximum: 200 }
    validate :validates_currently_completing_qualification, if: :missing_qualification?

    def self.build_from_qualification(qualification)
      new(
        qualification:,
        application_form: qualification.application_form,
        qualification_type: qualification.qualification_type,
        subject: qualification.subject,
        grade: qualification.grade,
        award_year: qualification.award_year,
        other_uk_qualification_type: qualification.other_uk_qualification_type,
        non_uk_qualification_type: qualification.non_uk_qualification_type,
        enic_reference: qualification.enic_reference,
        enic_reason: qualification.enic_reason,
        comparable_uk_qualification: qualification.comparable_uk_qualification,
        currently_completing_qualification: qualification.currently_completing_qualification,
        not_completed_explanation: qualification.not_completed_explanation,
        missing_explanation: qualification.missing_explanation,
        institution_country: qualification.institution_country,
      )
    end

    def assign_values(params)
      @qualification_type = qualification.qualification_type = params[:qualification_type]
      @grade = params[:grade]
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
      if gcse?
        qualification.update(
          award_year:,
          qualification_type:,
          grade:,
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

    def gcse?
      qualification_type == GCSE
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

    def non_uk_qualification?
      qualification_type == NON_UK_QUALIFICATION_TYPE
    end

    def other_uk_qualification?
      qualification_type == OTHER_UK_QUALIFICATION_TYPE
    end

    def validates_currently_completing_qualification
      unless currently_completing_qualification.in? [true, false]
        errors.add(
          :currently_completing_qualification,
          message: 'Choose an option if candidate is currently studying for a GCSE',
        )
      end
    end

    def reset_other_uk_qualification_type
      @other_uk_qualification_type = nil unless other_uk_qualification?
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

    def reset_missing_and_not_completed_explanations!(qualification)
      return true unless qualification.pass_gcse?

      qualification.update(missing_explanation: nil, not_completed_explanation: nil)
    end
  end
end
