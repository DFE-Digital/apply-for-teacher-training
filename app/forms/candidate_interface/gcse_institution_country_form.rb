module CandidateInterface
  class GcseInstitutionCountryForm
    include ActiveModel::Model

    attr_accessor :institution_country

    validates :institution_country, presence: true

    validates :institution_country,
              inclusion: { in: COUNTRIES_AND_TERRITORIES }

    def self.build_from_qualification(application_qualification)
      new(
        institution_country: application_qualification.institution_country,
      )
    end

    def save(application_qualification)
      return false unless valid?

      if FeatureFlag.active?('2027_international_qualifications_flow') && (institution_country != application_qualification.institution_country)
        application_qualification.update!(
          non_uk_qualification_type: nil,
          grade: nil,
          award_year: nil,
          enic_reason: nil,
          enic_reference: nil,
          not_completed_explanation: nil,
        )
      end

      application_qualification.update!(
        institution_country:,
      )
    end
  end
end
