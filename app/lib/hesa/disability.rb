module Hesa
  class Disability
    DisabilityStruct = Struct.new(:hesa_code, :value)

    def self.all
      HESA_DISABILITIES.map { |disability| DisabilityStruct.new(*disability) }
    end

    def self.find(value)
      converted_value = convert_to_hesa_value(value)
      all.find { |hesa_disability| hesa_disability.value == converted_value }
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
        'Deaf' => HesaDisabilityValues::DEAF,
        'Blind' => HesaDisabilityValues::BLIND,
        'Other' => HesaDisabilityValues::OTHER,
      }.freeze

      hesa_conversion[disability] || HesaDisabilityValues::OTHER
    end
  end
end
