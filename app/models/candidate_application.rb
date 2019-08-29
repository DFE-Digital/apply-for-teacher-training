class CandidateApplication < ApplicationRecord
  include AASM

  aasm column: 'state' do
    state :references_pending, initial: true
    state :application_complete
    state :offer_made
    state :meeting_conditions
    state :recruited
    state :enrolled

    event :submit_reference do
      transitions from: :references_pending, to: :application_complete, if: :done_by_referee?
    end

    event :set_conditions do
      transitions from: :application_complete, to: :offer_made, if: :done_by_provider?
    end

    event :accept_offer do
      transitions from: :offer_made, to: :meeting_conditions, if: :done_by_candidate?
    end

    event :confirm_conditions_met do
      transitions from: :meeting_conditions, to: :recruited, if: :done_by_provider?
    end

    event :confirm_onboarding do
      transitions from: :recruited, to: :enrolled, if: :done_by_provider?
    end
  end

  def done_by_referee?(actor)
    actor == 'referee'
  end

  def done_by_provider?(actor)
    actor == 'provider'
  end

  def done_by_candidate?(actor)
    actor == 'candidate'
  end
end
