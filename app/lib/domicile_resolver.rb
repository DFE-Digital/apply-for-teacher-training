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
      return hesa_code_for_uk_nil if uk_postcode.blank? || (prefix = uk_postcode.scan(/^[a-zA-Z]+/).first).blank?

      country_for_prefix = UK_AND_CI_POSTCODE_PREFIX_COUNTRIES.some { |r| r.prefixes.include?(prefix) }.first&.id || 'other'

      CODES_FOR_UK_AND_CI.one(country_for_prefix)&.code || hesa_code_for_other_uk
    end

    def hesa_code_for_region(uk_region)
      return hesa_code_for_uk_nil if uk_region.blank?
      return hesa_code_for_other_uk if (country_for_region = UK_REGION_COUNTRY_MAPPING.with_indifferent_access[uk_region]).blank?

      CODES_FOR_UK_AND_CI.one(country_for_region)&.code
    end

    def hesa_code_for_postcode_or_region(uk_postcode, uk_region)
      code_for_postcode = hesa_code_for_postcode(uk_postcode)

      if %w[ZZ XK].exclude?(code_for_postcode) || uk_region.blank?
        code_for_postcode
      else
        hesa_code_for_region(uk_region)
      end
    end

    def country_for_hesa_code(hesa_code)
      COUNTRIES_AND_TERRITORIES.one(hesa_code)&.name
    end

    def legacy_iso_to_valid_iso_mapping(iso_code)
      look_up = LEGACY_LOOK_UP_TABLE[iso_code]
      return nil if look_up.blank?

      hesa_code_for_country(look_up[:mapped_iso_code])
    end

  private

    def hesa_code_for_other_uk
      CODES_FOR_UK_AND_CI.one('other').code
    end

    def hesa_code_for_uk_nil
      CODES_FOR_UK_AND_CI.one(nil).code
    end
  end
end
