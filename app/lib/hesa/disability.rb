module Hesa
  class Disability
    DisabilityStruct = Struct.new(:hesa_code, :value)

    def self.all(cycle_year)
      collection_name = "HESA_DISABILITIES_#{cycle_year - 1}_#{cycle_year}"
      HesaDisabilityCollections.const_get(collection_name).map { |disability| DisabilityStruct.new(*disability) }
    rescue NameError
      raise ArgumentError, "Do not know Hesa Disability codes for #{cycle_year}"
    end

    def self.find(value, cycle_year = RecruitmentCycle.current_year)
      converted_value = convert_to_hesa_value(value)
      all(cycle_year).find { |hesa_disability| hesa_disability.value == converted_value }
    end

    def self.convert_to_hesa_value(disability)
      hesa_conversion = {
        'no' => HesaDisabilityValues::NONE,
        'Multiple' => HesaDisabilityValues::MULTIPLE,
        'Learning difficulty' => HesaDisabilityValues::LEARNING,
        'Social or communication impairment' => HesaDisabilityValues::SOCIAL_OR_COMMUNICATION,
        'Long-standing illness' => HesaDisabilityValues::LONGSTANDING_ILLNESS,
        'Mental health condition' => HesaDisabilityValues::MENTAL_HEALTH_CONDITION,
        'Physical disability or mobility issue' => HesaDisabilityValues::PHYSICAL_OR_MOBILITY,
        'Development condition' => HesaDisabilityValues::DEVELOPMENT_CONDITION,
        'Deaf' => HesaDisabilityValues::DEAF,
        'Blind' => HesaDisabilityValues::BLIND,
        'Other' => HesaDisabilityValues::OTHER,
      }.freeze

      hesa_conversion[disability] || HesaDisabilityValues::OTHER
    end
  end
end
