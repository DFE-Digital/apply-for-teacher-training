module HesaEthnicityTypes
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

# https://www.hesa.ac.uk/collection/c19053/e/ethnic
HESA_ETHNICITIES_2019_2020 = [
  [10, HesaEthnicityTypes::WHITE],
  [15, HesaEthnicityTypes::GYPSY_OR_TRAVELLER],
  [21, HesaEthnicityTypes::CARIBBEAN],
  [22, HesaEthnicityTypes::AFRICAN],
  [29, HesaEthnicityTypes::OTHER_BLACK],
  [31, HesaEthnicityTypes::INDIAN],
  [32, HesaEthnicityTypes::PAKISTANI],
  [33, HesaEthnicityTypes::BANGLADESHI],
  [34, HesaEthnicityTypes::CHINESE],
  [39, HesaEthnicityTypes::OTHER_ASIAN],
  [41, HesaEthnicityTypes::WHITE_AND_BLACK_CARIBBEAN],
  [42, HesaEthnicityTypes::WHITE_AND_BLACK_AFRICAN],
  [43, HesaEthnicityTypes::WHITE_AND_ASIAN],
  [49, HesaEthnicityTypes::OTHER_MIXED],
  [50, HesaEthnicityTypes::ARAB],
  [80, HesaEthnicityTypes::OTHER_ETHNIC],
  [90, HesaEthnicityTypes::NOT_KNOWN],
  [98, HesaEthnicityTypes::INFORMATION_REFUSED],
].freeze

# Two codes have been dropped in 2020/21
# https://www.hesa.ac.uk/collection/c20053/e/ethnic
HESA_ETHNICITIES_2020_2021 = HESA_ETHNICITIES_2019_2020
                               .reject { |ethnicity| [90, 98].include?(ethnicity.first) }
