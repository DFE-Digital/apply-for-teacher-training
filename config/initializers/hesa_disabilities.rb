module HesaChanges
  YEAR_2023 = 2023
end

module HesaDisabilityValues
  NONE = 'No known disability'.freeze
  MULTIPLE = 'Multiple disabilities'.freeze
  LEARNING = 'A specific learning difficulty such as dyslexia, dyspraxia or AD(H)D'.freeze
  SOCIAL_OR_COMMUNICATION = "A social/communication impairment such as Asperger's syndrome/other autistic spectrum disorder".freeze
  LONGSTANDING_ILLNESS = 'A long standing illness or health condition such as cancer, HIV, diabetes, chronic heart disease, or epilepsy'.freeze
  MENTAL_HEALTH_CONDITION = 'A mental health condition, such as depression, schizophrenia or anxiety disorder'.freeze
  PHYSICAL_OR_MOBILITY = 'A physical impairment or mobility issues, such as difficulty using arms or using a wheelchair or crutches'.freeze
  DEAF = 'Deaf or a serious hearing impairment'.freeze
  BLIND = 'Blind or a serious visual impairment uncorrected by glasses'.freeze
  OTHER = 'A disability, impairment or medical condition that is not listed above'.freeze
  PREFER_NOT_TO_SAY = 'Prefer not to say'.freeze
  NOT_AVAILABLE = 'Not available'.freeze
  DEVELOPMENT_CONDITION = 'Development condition that you have had since childhood which affects motor, cognitive, social and emotional skills, and speech and language'.freeze
end

module HesaDisabilityCollections
  def self.decorate_hesa_disabilities_with_reference_data(codes_and_original_names)
    codes_and_original_names.map do |hesa_code, original_name|
      reference_data = DfE::ReferenceData::EqualityAndDiversity::DISABILITIES_AND_HEALTH_CONDITIONS.some(
        hesa_code: hesa_code,
      ).first

      [
        hesa_code,
        original_name,
        reference_data.present? ? reference_data[:id] : nil,
      ]
    end
  end

  HESA_DISABILITY_CODES_2020_2021 = [
    ['00', HesaDisabilityValues::NONE],
    ['08', HesaDisabilityValues::MULTIPLE],
    ['51', HesaDisabilityValues::LEARNING],
    ['53', HesaDisabilityValues::SOCIAL_OR_COMMUNICATION],
    ['54', HesaDisabilityValues::LONGSTANDING_ILLNESS],
    ['55', HesaDisabilityValues::MENTAL_HEALTH_CONDITION],
    ['56', HesaDisabilityValues::PHYSICAL_OR_MOBILITY],
    ['57', HesaDisabilityValues::DEAF],
    ['58', HesaDisabilityValues::BLIND],
    ['96', HesaDisabilityValues::OTHER],
  ].freeze
  HESA_DISABILITIES_2020_2021 = decorate_hesa_disabilities_with_reference_data(
    HESA_DISABILITY_CODES_2020_2021,
  ).freeze

  HESA_DISABILITIES_2019_2020 = HESA_DISABILITIES_2020_2021
  HESA_DISABILITIES_2021_2022 = HESA_DISABILITIES_2020_2021

  HESA_DISABILITY_CODES_2022_2023 = [
    ['51', HesaDisabilityValues::LEARNING],
    ['53', HesaDisabilityValues::SOCIAL_OR_COMMUNICATION],
    ['54', HesaDisabilityValues::LONGSTANDING_ILLNESS],
    ['55', HesaDisabilityValues::MENTAL_HEALTH_CONDITION],
    ['56', HesaDisabilityValues::PHYSICAL_OR_MOBILITY],
    ['57', HesaDisabilityValues::DEAF],
    ['58', HesaDisabilityValues::BLIND],
    ['59', HesaDisabilityValues::DEVELOPMENT_CONDITION],
    ['95', HesaDisabilityValues::NONE],
    ['96', HesaDisabilityValues::OTHER],
    ['98', HesaDisabilityValues::PREFER_NOT_TO_SAY],
    ['99', HesaDisabilityValues::NOT_AVAILABLE],
  ].freeze
  HESA_DISABILITIES_2022_2023 = decorate_hesa_disabilities_with_reference_data(
    HESA_DISABILITY_CODES_2022_2023,
  ).freeze

  HESA_DISABILITIES_2023_2024 = HESA_DISABILITIES_2022_2023
  HESA_DISABILITIES_2024_2025 = HESA_DISABILITIES_2022_2023
  HESA_DISABILITIES_2025_2026 = HESA_DISABILITIES_2022_2023
  HESA_DISABILITIES_2026_2027 = HESA_DISABILITIES_2022_2023
end
