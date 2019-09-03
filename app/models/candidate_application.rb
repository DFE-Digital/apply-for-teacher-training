class CandidateApplication < ApplicationRecord
  include AASM

  aasm column: 'state' do
    state :unsubmitted, initial: true
    state :references_pending, before_enter: %i[record_submission_time assign_rejected_by_default_at]
    state :application_complete
    state :offer_made
    state :meeting_conditions
    state :recruited
    state :enrolled
    state :rejected

    event :submit do
      transitions from: :unsubmitted, to: :references_pending, if: :done_by_candidate?
    end

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

    event :reject, if: :done_by_provider? do
      transitions from: %i[references_pending application_complete offer_made meeting_conditions], to: :rejected
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

  def actions_for(actor)
    self.aasm.events({permitted: true}, actor).map(&:name)
  end

  def record_submission_time
    self.submitted_at = Time.now
  end

  def assign_rejected_by_default_at
    days_until_rejection = RejectByDefaultTimeframe
                             .applicable_at(Time.now)
                             .number_of_working_days_until_rejection
    self.rejected_by_default_at = days_until_rejection
                                    .business_days
                                    .after(Time.now.in_time_zone('London'))
                                    .end_of_day
  end
  
  # this method is going to be run by a background process
  def process_for_rejecting_applications
    if Time.now > self.rejected_by_default_at
      self.reject('provider')
    end
  end
end
