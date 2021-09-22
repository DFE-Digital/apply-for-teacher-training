class Vendor < ApplicationRecord
  enum name: {
    tribal: 'tribal',
    ellucian: 'ellucian',
    oracle: 'oracle',
    unit4: 'unit4',
    sap: 'sap',
    capita: 'capita',
    in_house: 'in_house',
  }

  has_many :providers
end
