module CandidateInterface
  class GcseEquivalentQualificationForm
    include ActiveModel::Model

    attr_accessor :qualification, :non_structured_qualification, :equivalent_qualifications

    validates :qualification, presence: true
    validates :non_structured_qualification, presence: true, if: :non_structured?
    validates :non_structured_qualification, length: { minimum: 2, maximum: ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH }, if: :non_structured?

    def self.build_from_qualification(application_qualification, equivalent_qualifications: [])
      qualification = application_qualification.non_uk_qualification_type
      structured = qualification.present? && qualification.in?(equivalent_qualifications)

      new(
        qualification: if structured
                         qualification
                       else
                         (qualification.present? ? 'other' : nil)
                       end,
        non_structured_qualification: structured ? nil : qualification,
      )
    end

    def save(application_qualification)
      return false unless valid?

      attributes = {
        non_uk_qualification_type: resolved_qualification,
      }

      if resolved_qualification != application_qualification.non_uk_qualification_type
        attributes.merge!(
          selected_grade_schema_id: nil,
          grade: nil,
        )
      end

      application_qualification.update!(attributes)
    end

    def non_structured?
      qualification == 'other'
    end

    def resolved_qualification
      non_structured? ? non_structured_qualification : qualification
    end
  end
end
