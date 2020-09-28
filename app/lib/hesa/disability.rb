module Hesa
  class Disability
    DisabilityStruct = Struct.new(:hesa_code, :type)

    def self.all
      HESA_DISABILITIES.map { |disability| DisabilityStruct.new(*disability) }
    end

    def self.find_by_type(disability_type)
      all.find { |disability| disability.type == disability_type }
    end

    def self.convert_to_hesa_type(disability)
      {
        'None' => HesaDisabilityTypes::NONE,
        'Multiple' => HesaDisabilityTypes::MULTIPLE,
        'Learning difficulty' => HesaDisabilityTypes::LEARNING,
        'Social or communication impairment' => HesaDisabilityTypes::SOCIAL_OR_COMMUNICATION,
        'Long-standing illness' => HesaDisabilityTypes::LONGSTANDING_ILLNESS,
        'Mental health condition' => HesaDisabilityTypes::MENTAL_HEALTH_CONDITION,
        'Physical disability or mobility issue' => HesaDisabilityTypes::PHYSICAL_OR_MOBILITY,
        'Deaf' => HesaDisabilityTypes::DEAF,
        'Blind' => HesaDisabilityTypes::BLIND,
        'Other' => HesaDisabilityTypes::OTHER,
      }.freeze[disability]
    end
  end
end
