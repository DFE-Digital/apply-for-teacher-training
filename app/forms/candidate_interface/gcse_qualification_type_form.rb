module CandidateInterface
  class GcseQualificationTypeForm
    OTHER_UK_QUALIFICATION_TYPE = 'other_uk'.freeze
    NON_UK_QUALIFICATION_TYPE = 'non_uk'.freeze
    include ActiveModel::Model

    attr_accessor :subject, :level, :qualification_type,
                  :other_uk_qualification_type, :non_uk_qualification_type

    validates :subject, :level, :qualification_type, presence: true

    validates :other_uk_qualification_type, presence: true, if: :other_uk_qualification?
    validates :non_uk_qualification_type, presence: true, if: :non_uk_qualification?
    validates :non_uk_qualification_type, :subject, :qualification_type, length: { maximum: 255 }
    validates :other_uk_qualification_type, length: { maximum: 100 }

    def self.build_from_qualification(qualification)
      new(
        level: qualification.level,
        subject: qualification.subject,
        qualification_type: qualification.qualification_type,
        other_uk_qualification_type: qualification.other_uk_qualification_type,
        non_uk_qualification_type: qualification.non_uk_qualification_type,
      )
    end

    def save(application_form)
      return false unless valid?

      reset_other_uk_qualification_type
      reset_non_uk_qualification_type

      application_form.application_qualifications.create(
        level: level,
        subject: subject,
        qualification_type: qualification_type,
        other_uk_qualification_type: other_uk_qualification_type,
        non_uk_qualification_type: non_uk_qualification_type,
      )
    end

    def update(qualification)
      return false unless valid?

      reset_other_uk_qualification_type
      reset_non_uk_qualification_type

      if missing_qualification?
        qualification.update!(
          qualification_type: qualification_type,
          grade: nil,
          constituent_grades: nil,
          award_year: nil,
          institution_name: nil,
          institution_country: nil,
          other_uk_qualification_type: nil,
          non_uk_qualification_type: nil,
        )
      else
        qualification.update!(
          qualification_type: qualification_type,
          other_uk_qualification_type: other_uk_qualification_type,
          non_uk_qualification_type: non_uk_qualification_type,
        )
      end
    end

    def missing_qualification?
      qualification_type == 'missing'
    end

  private

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
      end
    end
  end
end
