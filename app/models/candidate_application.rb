class CandidateApplication < ApplicationRecord
  include AASM

  aasm column: 'state' do
    state :references_pending, initial: true
    state :application_complete

    event :submit_reference do
      transitions from: :references_pending, to: :application_complete, if: :done_by_referee?
    end
  end

  def done_by_referee?(actor)
    actor == 'referee'
  end
end
