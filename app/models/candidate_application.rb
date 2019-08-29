class CandidateApplication < ApplicationRecord
  include AASM

  aasm column: 'state' do
    state :references_pending, initial: true
    state :application_complete
    state :offer_made

    event :submit_reference do
      transitions from: :references_pending, to: :application_complete, if: :done_by_referee?
    end

    event :set_conditions do
      transitions from: :application_complete, to: :offer_made, if: :done_by_provider?
    end
  end

  def done_by_referee?(actor)
    actor == 'referee'
  end

  def done_by_provider?(actor)
    actor == 'provider'
  end
end
