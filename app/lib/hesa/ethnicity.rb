module Hesa
  class Ethnicity
    EthnicityStruct = Struct.new(:hesa_code, :type)

    def self.all(cycle_year)
      if cycle_year == 2020
        HESA_ETHNICITIES_2019_2020.map { |ethnicity| EthnicityStruct.new(*ethnicity) }
      elsif cycle_year == 2021
        HESA_ETHNICITIES_2020_2021.map { |ethnicity| EthnicityStruct.new(*ethnicity) }
      else
        raise ArgumentError, "Do not know Hesa Ethnicities codes for #{recruitment_cycle_year}"
      end
    end

    def self.find_by_type(ethnicity_type, cycle_year)
      all(cycle_year).find { |ethnicity| ethnicity.type == ethnicity_type }
    end

    def self.convert_to_hesa_type(background)
      {
        'British, English, Northern Irish, Scottish, or Welsh' => HesaEthnicityTypes::WHITE,
        'Irish' => HesaEthnicityTypes::WHITE,
        'Irish Traveller or Gypsy' => HesaEthnicityTypes::GYPSY_OR_TRAVELLER,
        'Another White background' => HesaEthnicityTypes::WHITE,
        'Prefer not to say' => HesaEthnicityTypes::INFORMATION_REFUSED,
        'Bangladeshi' => HesaEthnicityTypes::BANGLADESHI,
        'Chinese' => HesaEthnicityTypes::CHINESE,
        'Indian' => HesaEthnicityTypes::INDIAN,
        'Pakistani' => HesaEthnicityTypes::PAKISTANI,
        'Another Asian background' => HesaEthnicityTypes::OTHER_ASIAN,
        'African' => HesaEthnicityTypes::AFRICAN,
        'Caribbean' => HesaEthnicityTypes::CARIBBEAN,
        'Another Black background' => HesaEthnicityTypes::OTHER_BLACK,
        'Asian and White' => HesaEthnicityTypes::WHITE_AND_ASIAN,
        'Black African and White' => HesaEthnicityTypes::WHITE_AND_BLACK_AFRICAN,
        'Black Caribbean and White' => HesaEthnicityTypes::WHITE_AND_BLACK_CARIBBEAN,
        'Another Mixed background' => HesaEthnicityTypes::OTHER_MIXED,
        'Arab' => HesaEthnicityTypes::ARAB,
        'Another ethnic background' => HesaEthnicityTypes::OTHER_ETHNIC,
      }.freeze[background]
    end
  end
end
