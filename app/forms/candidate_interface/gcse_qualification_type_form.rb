module CandidateInterface
  class GcseQualificationTypeForm
    OTHER_UK_QUALIFICATION_TYPE = 'other_uk'.freeze
    NON_UK_QUALIFICATION_TYPE = 'non_uk'.freeze
    include ActiveModel::Model

    attr_accessor :subject, :level, :qualification_type,
                  :other_uk_qualification_type, :non_uk_qualification_type,
                  :enic_reference, :comparable_uk_qualification

    validates :subject, :level, :qualification_type, presence: true

    validates :other_uk_qualification_type, presence: true, if: :other_uk_qualification?
    validates :non_uk_qualification_type, presence: true, if: :non_uk_qualification?
    validates :non_uk_qualification_type, :subject, :qualification_type, length: { maximum: ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH }
    validates :other_uk_qualification_type, length: { maximum: 100 }

    def self.build_from_qualification(qualification)
      new(
        level: qualification.level,
        subject: qualification.subject,
        qualification_type: qualification.qualification_type,
        other_uk_qualification_type: qualification.other_uk_qualification_type,
        non_uk_qualification_type: qualification.non_uk_qualification_type,
        enic_reference: qualification.enic_reference,
        comparable_uk_qualification: qualification.comparable_uk_qualification,
      )
    end

    def save(application_form)
      return false unless valid?

      reset_other_uk_qualification_type
      reset_non_uk_qualification_type

      application_form.application_qualifications.create(
        level:,
        subject:,
        qualification_type:,
        other_uk_qualification_type:,
        non_uk_qualification_type:,
        enic_reference:,
        comparable_uk_qualification:,
      )
    end

    def update(qualification)
      return false unless valid?

      reset_other_uk_qualification_type
      reset_non_uk_qualification_type

      attributes = {
        qualification_type:,
        other_uk_qualification_type:,
        non_uk_qualification_type:,
        enic_reference:,
        comparable_uk_qualification:,
        currently_completing_qualification: nil,
        not_completed_explanation: nil,
        missing_explanation: nil,
      }

      if qualification_type_changed?(qualification)
        attributes[:grade] = nil
        attributes[:constituent_grades] = nil
      end

      if missing_qualification?
        attributes.merge!(
          grade: nil,
          constituent_grades: nil,
          award_year: nil,
          institution_name: nil,
          institution_country: nil,
          other_uk_qualification_type: nil,
          non_uk_qualification_type: nil,
          enic_reference: nil,
          comparable_uk_qualification: nil,
        )
      end

      qualification.update!(attributes)
    end

    def missing_qualification?
      qualification_type == 'missing'
    end

  private

    def qualification_type_changed?(qualification)
      qualification_type != qualification.qualification_type
    end

    def non_uk_qualification?
      qualification_type == NON_UK_QUALIFICATION_TYPE
    end

    def other_uk_qualification?
      qualification_type == OTHER_UK_QUALIFICATION_TYPE
    end

    def reset_other_uk_qualification_type
      if qualification_type != OTHER_UK_QUALIFICATION_TYPE
        @other_uk_qualification_type = nil
      end
    end

    def reset_non_uk_qualification_type
      if qualification_type != NON_UK_QUALIFICATION_TYPE
        @non_uk_qualification_type = nil
        @enic_reference = nil
        @comparable_uk_qualification = nil
      end
    end
  end
end
