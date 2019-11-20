module CandidateInterface
  class GcseQualificationTypeForm
    OTHER_UK_QUALIFICATION_TYPE = 'other_uk'.freeze
    MISSING_QUALIFICATION_TYPE = 'missing'.freeze

    include ActiveModel::Model

    attr_accessor :subject, :level, :qualification_type, :other_uk_qualification_type,
                  :missing_explanation, :qualification_id

    validates :subject, :level, :qualification_type, presence: true

    validates :other_uk_qualification_type, presence: true, if: -> { qualification_type == OTHER_UK_QUALIFICATION_TYPE }
    validates :other_uk_qualification_type, length: { maximum: 100 }

    validates :missing_explanation, word_count: { maximum: 200 }

    def save_base(application_form)
      return false unless valid?

      reset_other_uk_qualification_type

      if new_record?
        application_form.application_qualifications.create(
          level: level,
          subject: subject,
          qualification_type: qualification_type,
          other_uk_qualification_type: other_uk_qualification_type,
          missing_explanation: missing_explanation,
        )
      else
        qualification = ApplicationQualification.find(qualification_id)

        qualification.update(
          level: level,
          subject: subject,
          qualification_type: qualification_type,
          other_uk_qualification_type: other_uk_qualification_type,
          missing_explanation: missing_explanation,
        )
      end
    end

    def set_attributes(params)
      @qualification_type = params[:qualification_type]
      @other_uk_qualification_type = params[:other_uk_qualification_type]
      @missing_explanation = params[:missing_explanation]
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
        qualification_id: qualification.id,
        missing_explanation: qualification.missing_explanation,
      )
    end

    def new_record?
      qualification_id.nil?
    end

  private

    def reset_other_uk_qualification_type
      if qualification_type != OTHER_UK_QUALIFICATION_TYPE
        @other_uk_qualification_type = nil
      end
    end
  end
end
