require 'dfe/reference_data/countries_and_territories'
require 'dfe/reference_data/hesa/domiciles'

COUNTRIES_AND_TERRITORIES = DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES
  .all_as_hash.transform_values(&:name).freeze

CODES_AND_NATIONALITIES = DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES
                            .all_as_hash
                            .transform_values(&:citizen_names)
                            .reject{ |_k, v| v == 'Not applicable' }

DOMICILES = DfE::ReferenceData::HESA::Domiciles::COUNTRIES_AND_TERRITORIES.all_as_hash.transform_values(&:name).freeze
