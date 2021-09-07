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
  ].freeze

  # Two codes have been dropped in 2020/21
  # https://www.hesa.ac.uk/collection/c20053/e/ethnic
  HESA_ETHNICITIES_2020_2021 = HESA_ETHNICITIES_2019_2020
                                 .reject { |ethnicity| %w[90 98].include?(ethnicity.first) }
  # Unchanged from 2020-2021
  # https://www.hesa.ac.uk/collection/c21053/e/ethnic
  HESA_ETHNICITIES_2021_2022 = HESA_ETHNICITIES_2020_2021
end
