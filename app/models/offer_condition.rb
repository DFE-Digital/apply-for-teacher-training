class OfferCondition < ApplicationRecord
  belongs_to :offer
  has_one :application_choice, through: :offer

  enum status: {
    pending: 'pending',
    met: 'met',
    unmet: 'unmet',
  }

  audited associated_with: :application_choice
end
