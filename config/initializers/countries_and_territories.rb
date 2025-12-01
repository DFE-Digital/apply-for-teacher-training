require 'dfe/reference_data/countries_and_territories'

COUNTRIES_AND_TERRITORIES = DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES
  .all_as_hash.transform_values(&:name).freeze

CODES_AND_NATIONALITIES = DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES.all_as_hash.transform_values(&:citizen_names)
