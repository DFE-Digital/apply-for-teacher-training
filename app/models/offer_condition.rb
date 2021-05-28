class OfferCondition < ApplicationRecord
  belongs_to :offer
  has_one :application_choice, through: :offer

  enum status: {
    pending: 'pending',
    met: 'met',
    unmet: 'unmet',
  }
end
