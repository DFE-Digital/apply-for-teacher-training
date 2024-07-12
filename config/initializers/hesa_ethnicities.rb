module HesaEthnicityValues
  WHITE = 'White'.freeze
  GYPSY_OR_TRAVELLER = 'Gypsy or Traveller'.freeze
  CARIBBEAN = 'Black or Black British - Caribbean'.freeze
  AFRICAN = 'Black or Black British - African'.freeze
  OTHER_BLACK = 'Other Black background'.freeze
  BANGLADESHI = 'Asian or Asian British - Bangladeshi'.freeze
  INDIAN = 'Asian or Asian British - Indian'.freeze
  PAKISTANI = 'Asian or Asian British - Pakistani'.freeze
  CHINESE = 'Chinese'.freeze
  OTHER_ASIAN = 'Other Asian background'.freeze
  WHITE_AND_BLACK_CARIBBEAN = 'Mixed - White and Black Caribbean'.freeze
  WHITE_AND_BLACK_AFRICAN = 'Mixed - White and Black African'.freeze
  WHITE_AND_ASIAN = 'Mixed - White and Asian'.freeze
  OTHER_MIXED = 'Other Mixed background'.freeze
  ARAB = 'Arab'.freeze
  OTHER_ETHNIC = 'Other Ethnic background'.freeze
  NOT_KNOWN = 'Not known'.freeze
  INFORMATION_REFUSED = 'Information refused'.freeze
  PREFER_NOT_TO_SAY = 'Prefer not to say'.freeze
  NOT_AVAILABLE = 'Not available'.freeze
  WHITE_IRISH = 'White - Irish'.freeze
  WHITE_ROMA = 'White - Roma'.freeze
  OTHER_WHITE = 'Any other White background'.freeze
end

module HesaEthnicityCollections
  # https://www.hesa.ac.uk/collection/c19053/e/ethnic
  HESA_ETHNICITIES_2019_2020 = [
    ['10', HesaEthnicityValues::WHITE],
    ['15', HesaEthnicityValues::GYPSY_OR_TRAVELLER],
    ['21', HesaEthnicityValues::CARIBBEAN],
    ['22', HesaEthnicityValues::AFRICAN],
    ['29', HesaEthnicityValues::OTHER_BLACK],
    ['31', HesaEthnicityValues::INDIAN],
    ['32', HesaEthnicityValues::PAKISTANI],
    ['33', HesaEthnicityValues::BANGLADESHI],
    ['34', HesaEthnicityValues::CHINESE],
    ['39', HesaEthnicityValues::OTHER_ASIAN],
    ['41', HesaEthnicityValues::WHITE_AND_BLACK_CARIBBEAN],
    ['42', HesaEthnicityValues::WHITE_AND_BLACK_AFRICAN],
    ['43', HesaEthnicityValues::WHITE_AND_ASIAN],
    ['49', HesaEthnicityValues::OTHER_MIXED],
    ['50', HesaEthnicityValues::ARAB],
    ['80', HesaEthnicityValues::OTHER_ETHNIC],
    ['90', HesaEthnicityValues::NOT_KNOWN],
    ['98', HesaEthnicityValues::INFORMATION_REFUSED],
    # For backward compatibility
    ['98', HesaEthnicityValues::PREFER_NOT_TO_SAY],
  ].freeze

  HESA_ETHNICITIES_2022_2023 = [
    ['180', HesaEthnicityValues::ARAB],
    ['100', HesaEthnicityValues::BANGLADESHI],
    ['101', HesaEthnicityValues::CHINESE],
    ['103', HesaEthnicityValues::INDIAN],
    ['104', HesaEthnicityValues::PAKISTANI],
    ['119', HesaEthnicityValues::OTHER_ASIAN],
    ['120', HesaEthnicityValues::AFRICAN],
    ['121', HesaEthnicityValues::CARIBBEAN],
    ['139', HesaEthnicityValues::OTHER_BLACK],
    ['140', HesaEthnicityValues::WHITE_AND_ASIAN],
    ['141', HesaEthnicityValues::WHITE_AND_BLACK_AFRICAN],
    ['142', HesaEthnicityValues::WHITE_AND_BLACK_CARIBBEAN],
    ['159', HesaEthnicityValues::OTHER_MIXED],
    ['160', HesaEthnicityValues::WHITE],
    ['163', HesaEthnicityValues::GYPSY_OR_TRAVELLER],
    ['166', HesaEthnicityValues::WHITE_IRISH],
    ['168', HesaEthnicityValues::WHITE_ROMA],
    ['179', HesaEthnicityValues::OTHER_WHITE],
    ['899', HesaEthnicityValues::OTHER_ETHNIC],
    ['997', HesaEthnicityValues::NOT_KNOWN],
    ['998', HesaEthnicityValues::PREFER_NOT_TO_SAY],
    ['999', HesaEthnicityValues::NOT_AVAILABLE],
  ].freeze

  # https://www.hesa.ac.uk/collection/c20053/e/ethnic
  HESA_ETHNICITIES_2020_2021 = HESA_ETHNICITIES_2019_2020
  # Unchanged from 2020-2021
  # https://www.hesa.ac.uk/collection/c21053/e/ethnic
  HESA_ETHNICITIES_2021_2022 = HESA_ETHNICITIES_2020_2021

  HESA_ETHNICITIES_2023_2024 = HESA_ETHNICITIES_2022_2023
  HESA_ETHNICITIES_2024_2025 = HESA_ETHNICITIES_2022_2023
end
