module HesaDisabilityTypes
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
end

# https://www.hesa.ac.uk/collection/c20053/e/disable
HESA_DISABILITIES = [
  ['00', HesaDisabilityTypes::NONE],
  ['08', HesaDisabilityTypes::MULTIPLE],
  ['51', HesaDisabilityTypes::LEARNING],
  ['53', HesaDisabilityTypes::SOCIAL_OR_COMMUNICATION],
  ['54', HesaDisabilityTypes::LONGSTANDING_ILLNESS],
  ['55', HesaDisabilityTypes::MENTAL_HEALTH_CONDITION],
  ['56', HesaDisabilityTypes::PHYSICAL_OR_MOBILITY],
  ['57', HesaDisabilityTypes::DEAF],
  ['58', HesaDisabilityTypes::BLIND],
  ['96', HesaDisabilityTypes::OTHER],
].freeze
