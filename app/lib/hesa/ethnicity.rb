module Hesa
  class Ethnicity
    EthnicityStruct = Struct.new(:hesa_code, :value)

    def self.all(cycle_year)
      collection_name = "HESA_ETHNICITIES_#{cycle_year - 1}_#{cycle_year}"
      HesaEthnicityCollections.const_get(collection_name).map { |ethnicity| EthnicityStruct.new(*ethnicity) }
    rescue NameError
      raise ArgumentError, "Do not know Hesa Ethnicities codes for #{cycle_year}"
    end

    def self.find(value, cycle_year)
      converted_value = convert_to_hesa_value(value)
      all(cycle_year).find { |hesa_ethnicity| hesa_ethnicity.value == converted_value }
    end

    def self.find_without_conversion(value, cycle_year)
      Hesa::Ethnicity.all(cycle_year).find { |ethnicity| ethnicity.value == value }
    end

    def self.convert_to_hesa_value(background)
      hesa_conversion = {
        'British, English, Northern Irish, Scottish, or Welsh' => HesaEthnicityValues::WHITE,
        'Irish' => HesaEthnicityValues::WHITE_IRISH,
        'Roma' => HesaEthnicityValues::WHITE_ROMA,
        'Irish Traveller or Gypsy' => HesaEthnicityValues::GYPSY_OR_TRAVELLER,
        'Another White background' => HesaEthnicityValues::OTHER_WHITE,
        'Prefer not to say' => HesaEthnicityValues::PREFER_NOT_TO_SAY,
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
