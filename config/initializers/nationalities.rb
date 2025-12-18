require 'dfe/reference_data/countries_and_territories'

NATIONALITIES = DfE::ReferenceData::CountriesAndTerritories::COUNTRIES_AND_TERRITORIES.all.map do |n|
  [n.id, n.id == 'GB' ? 'British' : n.citizen_names]
end
NATIONALITIES_BY_NAME = NATIONALITIES.map(&:reverse).to_h
NATIONALITIES_BY_CODE = NATIONALITIES.to_h
NATIONALITY_DEMONYMS = CODES_AND_NATIONALITIES.map(&:second)

UK_COUNTRY_CODE = ['GB']

EU_COUNTRY_CODES = [
  'AX',
  'AT',
  'BE',
  'BG',
  'HR',
  'CY',
  'CZ',
  'DK',
  'EE',
  'FO',
  'FI',
  'FR',
  'GF',
  'DE',
  'GI',
  'GR',
  'HU',
  'IE',
  'IM',
  'IT',
  'LV',
  'LT',
  'LU',
  'MT',
  'NL',
  'PL',
  'PT',
  'RO',
  'SK',
  'SI',
  'ES',
  'SE',
  'XA',
].freeze

PROVISIONALLY_ELIGIBLE_FOR_GOV_FUNDING_COUNTRY_CODES = %w[GB IE IM].freeze
EU_EEA_SWISS_COUNTRY_CODES = (EU_COUNTRY_CODES + ['IS', 'LI', 'NO', 'CH']).freeze

UK_NATIONALITIES = ['British', 'Welsh', 'Scottish', 'Northern Irish', 'English'].freeze
UK_AND_IRISH_NATIONALITIES = (UK_NATIONALITIES + ['Irish']).freeze
