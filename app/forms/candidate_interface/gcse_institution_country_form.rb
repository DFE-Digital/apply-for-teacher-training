module CandidateInterface
  class GcseInstitutionCountryForm
    include ActiveModel::Model

    attr_accessor :institution_country

    validates :institution_country,
              inclusion: { in: COUNTRIES_BY_NAME }

    def self.build_from_qualification(application_qualification)
      new(
        institution_country: application_qualification.institution_country,
      )
    end

    def save(application_qualification)
      return false unless valid?

      application_qualification.update!(
        institution_country: institution_country,
      )
    end
  end
end
