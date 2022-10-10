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

    def self.convert_to_hesa_value(background)
      hesa_conversion = {
        'English, Welsh, Scottish, Northern Irish or British' => HesaEthnicityValues::WHITE,
        'Irish' => HesaEthnicityValues::WHITE_IRISH,
        'Roma' => HesaEthnicityValues::WHITE_ROMA,
        'Gypsy or Irish Traveller' => HesaEthnicityValues::GYPSY_OR_TRAVELLER,
        'Any other White background' => HesaEthnicityValues::WHITE,
        'Prefer not to say' => HesaEthnicityValues::INFORMATION_REFUSED,
        'Bangladeshi' => HesaEthnicityValues::BANGLADESHI,
        'Chinese' => HesaEthnicityValues::CHINESE,
        'Indian' => HesaEthnicityValues::INDIAN,
        'Pakistani' => HesaEthnicityValues::PAKISTANI,
        'Any other Asian background' => HesaEthnicityValues::OTHER_ASIAN,
        'African' => HesaEthnicityValues::AFRICAN,
        'Caribbean' => HesaEthnicityValues::CARIBBEAN,
        'Any other Black, African or Caribbean background' => HesaEthnicityValues::OTHER_BLACK,
        'White and Asian' => HesaEthnicityValues::WHITE_AND_ASIAN,
        'White and Black African ' => HesaEthnicityValues::WHITE_AND_BLACK_AFRICAN,
        'White and Black Caribbean' => HesaEthnicityValues::WHITE_AND_BLACK_CARIBBEAN,
        'Any other mixed or multiple ethnic background' => HesaEthnicityValues::OTHER_MIXED,
        'Arab' => HesaEthnicityValues::ARAB,
        'Another ethnic background' => HesaEthnicityValues::OTHER_ETHNIC,
      }.freeze

      hesa_conversion[background] || HesaEthnicityValues::NOT_KNOWN
    end
  end
end
