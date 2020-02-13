class ChaserSent < ApplicationRecord
  belongs_to :chased, polymorphic: true

  enum chaser_type: {
    reference_request: 'reference_request',
    reference_replacement: 'reference_replacement',
    provider_decision_request: 'provider_decision_request',
  }
end
