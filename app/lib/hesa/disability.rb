module Hesa
  class Disability
    DisabilityStruct = Struct.new(:hesa_code, :value)
    HESA_CONVERSION = {
      'Autistic spectrum condition or another condition affecting speech, language, communication or social skills' => HesaDisabilityValues::SOCIAL_OR_COMMUNICATION,
      'Blindness or a visual impairment not corrected by glasses' => HesaDisabilityValues::BLIND,
      'Condition affecting motor, cognitive, social and emotional skills, speech or language since childhood' => HesaDisabilityValues::DEVELOPMENT_CONDITION,
      'Deafness or a serious hearing impairment' => HesaDisabilityValues::DEAF,
      'Dyslexia, dyspraxia or attention deficit hyperactivity disorder (ADHD) or another learning difference' => HesaDisabilityValues::LEARNING,
      'Long-term illness' => HesaDisabilityValues::LONGSTANDING_ILLNESS,
      'Mental health condition' => HesaDisabilityValues::MENTAL_HEALTH_CONDITION,
      'Physical disability or mobility issue' => HesaDisabilityValues::PHYSICAL_OR_MOBILITY,
      'Another disability, health condition or impairment affecting daily life' => HesaDisabilityValues::OTHER,
      'I do not have any of these disabilities or health conditions' => HesaDisabilityValues::NONE,
      'Prefer not to say' => HesaDisabilityValues::PREFER_NOT_TO_SAY,
    }.freeze

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
      HESA_CONVERSION[disability] || HesaDisabilityValues::OTHER
    end
  end
end
