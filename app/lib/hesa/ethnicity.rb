module Hesa
  class Ethnicity
    EthnicityStruct = Struct.new(:hesa_code, :value)

    def self.all(cycle_year)
      if cycle_year == 2020
        HESA_ETHNICITIES_2019_2020.map { |ethnicity| EthnicityStruct.new(*ethnicity) }
      elsif cycle_year == 2021
        HESA_ETHNICITIES_2020_2021.map { |ethnicity| EthnicityStruct.new(*ethnicity) }
      else
        raise ArgumentError, "Do not know Hesa Ethnicities codes for #{cycle_year}"
      end
    end

    def self.find(value, cycle_year)
      converted_value = convert_to_hesa_value(value)
      all(cycle_year).find { |hesa_ethnicity| hesa_ethnicity.value == converted_value }
    end

    def self.convert_to_hesa_value(background)
      hesa_conversion = {
        'British, English, Northern Irish, Scottish, or Welsh' => HesaEthnicityValues::WHITE,
        'Irish' => HesaEthnicityValues::WHITE,
        'Irish Traveller or Gypsy' => HesaEthnicityValues::GYPSY_OR_TRAVELLER,
        'Another White background' => HesaEthnicityValues::WHITE,
        'Prefer not to say' => HesaEthnicityValues::INFORMATION_REFUSED,
        'Bangladeshi' => HesaEthnicityValues::BANGLADESHI,
        'Chinese' => HesaEthnicityValues::CHINESE,
        'Indian' => HesaEthnicityValues::INDIAN,
        'Pakistani' => HesaEthnicityValues::PAKISTANI,
        'Another Asian background' => HesaEthnicityValues::OTHER_ASIAN,
        'African' => HesaEthnicityValues::AFRICAN,
        'Caribbean' => HesaEthnicityValues::CARIBBEAN,
        'Another Black background' => HesaEthnicityValues::OTHER_BLACK,
        'Asian and White' => HesaEthnicityValues::WHITE_AND_ASIAN,
        'Black African and White' => HesaEthnicityValues::WHITE_AND_BLACK_AFRICAN,
        'Black Caribbean and White' => HesaEthnicityValues::WHITE_AND_BLACK_CARIBBEAN,
        'Another Mixed background' => HesaEthnicityValues::OTHER_MIXED,
        'Arab' => HesaEthnicityValues::ARAB,
        'Another ethnic background' => HesaEthnicityValues::OTHER_ETHNIC,
      }.freeze

      hesa_conversion[background] || HesaEthnicityValues::NOT_KNOWN
    end
  end
end
