module CandidateInterface
  class GcseInstitutionCountryForm
    include ActiveModel::Model
    include FreeTextInputHelper

    attr_accessor :institution_country, :institution_country_raw

    alias value institution_country
    alias raw_input institution_country_raw

    def valid_options
      COUNTRIES_AND_TERRITORIES.map do |iso_code, country_name|
        [country_name, iso_code]
      end.unshift([nil, nil])
    end

    validate :no_free_text_input
    validates :institution_country, presence: true

    def self.build_from_qualification(application_qualification)
      new(
        institution_country: application_qualification.institution_country,
      )
    end

    def initialize(attributes = {})
      super
      if institution_country_raw.present?
        @institution_country = COUNTRIES_AND_TERRITORIES.find do |_iso_code, country_name|
          country_name == institution_country_raw
        end&.first || institution_country_raw
      end
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

  private

    def no_free_text_input
      errors.add(:institution_country, :inclusion) if invalid_raw_data?
    end

    def institution_country_selected
      errors.add(:institution_country, :blank) if institution_country_raw.blank?
    end
  end
end
