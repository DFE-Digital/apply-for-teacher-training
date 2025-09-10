require 'dfe/reference_data/hesa/domiciles'
require 'dfe/reference_data/countries_and_territories'

class DomicileResolver
  # This class is different from the CountryFinder and both are necessary.
  # This returns the hesa data for reporting only.
  # The CountryFinder returns the data a user inputted via the iso code.
  CODES_FOR_UK_AND_CI = DfE::ReferenceData::HESA::Domiciles::CODES_FOR_UK_AND_CI
  COUNTRIES_AND_TERRITORIES = DfE::ReferenceData::HESA::Domiciles::COUNTRIES_AND_TERRITORIES
  SPECIAL_ISO_CODES = DfE::ReferenceData::HESA::Domiciles::SPECIAL_ISO_CODES
  UK_AND_CI_POSTCODE_PREFIX_COUNTRIES = DfE::ReferenceData::CountriesAndTerritories::UK_AND_CI_POSTCODE_PREFIX_COUNTRIES

  class << self
    def hesa_code_for_country(iso_country_code)
      SPECIAL_ISO_CODES.one(iso_country_code)&.code ||
        legacy_iso_to_valid_iso_mapping(iso_country_code) ||
        iso_country_code
    end

    def hesa_code_for_postcode(uk_postcode)
      return CODES_FOR_UK_AND_CI.one(nil).code if uk_postcode.blank? || (prefix = uk_postcode.scan(/^[a-zA-Z]+/).first).blank?

      country_for_prefix = UK_AND_CI_POSTCODE_PREFIX_COUNTRIES.some { |r| r.prefixes.include?(prefix) }.first&.id || 'other'

      CODES_FOR_UK_AND_CI.one(country_for_prefix)&.code || CODES_FOR_UK_AND_CI.one('other').code
    end

    def country_for_hesa_code(hesa_code)
      COUNTRIES_AND_TERRITORIES.one(hesa_code)&.name
    end

    def legacy_iso_to_valid_iso_mapping(iso_code)
      look_up = LEGACY_LOOK_UP_TABLE[iso_code]
      return nil if look_up.blank?

      hesa_code_for_country(look_up[:mapped_iso_code])
    end
  end
end
