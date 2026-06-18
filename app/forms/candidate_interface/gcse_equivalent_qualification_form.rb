module CandidateInterface
  class GcseEquivalentQualificationForm
    include ActiveModel::Model

    attr_accessor :qualification, :non_structured_qualification, :equivalent_qualifications

    validates :qualification, presence: true
    validates :non_structured_qualification, presence: true, if: :non_structured?
    validates :non_structured_qualification, length: { maximum: ApplicationQualification::MAX_QUALIFICATION_TYPE_LENGTH }

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

      application_qualification.update!(
        non_uk_qualification_type: non_structured? ? non_structured_qualification : qualification,
      )
    end

    def non_structured?
      qualification == 'other'
    end
  end
end
