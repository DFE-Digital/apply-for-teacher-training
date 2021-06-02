module CandidateInterface
  class GcseQualificationTypeForm
    OTHER_UK_QUALIFICATION_TYPE = 'other_uk'.freeze
    NON_UK_QUALIFICATION_TYPE = 'non_uk'.freeze
    include ActiveModel::Model

    attr_accessor :subject, :level, :qualification_type, :other_uk_qualification_type,
                  :missing_explanation, :qualification_id, :non_uk_qualification_type

    validates :subject, :level, :qualification_type, presence: true

    validates :other_uk_qualification_type, presence: true, if: -> { qualification_type == OTHER_UK_QUALIFICATION_TYPE }
    validates :non_uk_qualification_type, presence: true, if: -> { qualification_type == NON_UK_QUALIFICATION_TYPE }
    validates :qualification_type, length: { maximum: 255 }
    validates :other_uk_qualification_type, :non_uk_qualification_type, length: { maximum: 255 }

    validates :missing_explanation, word_count: { maximum: 200 }

    validates :subject, length: { maximum: 255 }

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
        missing_explanation: missing_explanation,
      )
    end

    def update(qualification)
      return false unless valid?

      reset_other_uk_qualification_type
      reset_non_uk_qualification_type

      qualification.update(
        level: level,
        subject: subject,
        qualification_type: qualification_type,
        other_uk_qualification_type: other_uk_qualification_type,
        non_uk_qualification_type: non_uk_qualification_type,
        missing_explanation: missing_explanation,
      )
    end

    def missing_qualification?
      qualification_type == 'missing'
    end

    def self.build_from_qualification(qualification)
      new(
        level: qualification.level,
        subject: qualification.subject,
        qualification_type: qualification.qualification_type,
        other_uk_qualification_type: qualification.other_uk_qualification_type,
        non_uk_qualification_type: qualification.non_uk_qualification_type,
        qualification_id: qualification.id,
        missing_explanation: qualification.missing_explanation,
      )
    end

  private

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
