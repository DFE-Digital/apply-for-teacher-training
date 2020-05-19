class ChaserSent < ApplicationRecord
  belongs_to :chased, polymorphic: true

  enum chaser_type: {
    reference_request: 'reference_request',
    reference_replacement: 'reference_replacement',
    additional_reference_request: 'additional_reference_request',
    provider_decision_request: 'provider_decision_request',
    candidate_decision_request: 'candidate_decision_request',
  }
end
