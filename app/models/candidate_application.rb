class CandidateApplication < ApplicationRecord
  include AASM

  belongs_to :course, optional: true

  scope :with_rbd_times_in_the_past, -> { where('rejected_by_default_at < ?', Time.now) }
  scope :pre_offer, -> { where(state: %i[unsubmitted references_pending application_complete]) }

  # rubocop:disable Metrics/BlockLength
  aasm column: 'state' do
    state :unsubmitted, initial: true
    state :references_pending, before_enter: %i[record_submission_time assign_rejected_by_default_at]
    state :application_complete
    state :conditional_offer
    state :unconditional_offer
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

    event :make_conditional_offer do
      transitions from: :application_complete, to: :conditional_offer, if: :done_by_provider?
    end

    event :make_unconditional_offer do
      transitions from: :application_complete, to: :unconditional_offer, if: :done_by_provider?
    end

    event :accept_offer do
      transitions from: :conditional_offer, to: :meeting_conditions, if: :done_by_candidate?
      transitions from: :unconditional_offer, to: :recruited, if: :done_by_candidate?
    end

    event :confirm_conditions_met do
      transitions from: :meeting_conditions, to: :recruited, if: :done_by_provider?
    end

    event :confirm_onboarding do
      transitions from: :recruited, to: :enrolled, if: :done_by_provider?
    end

    event :reject, if: :done_by_provider? do
      transitions from: %i[references_pending application_complete conditional_offer unconditional_offer meeting_conditions], to: :rejected
    end

    event :add_conditions, if: %i[done_by_provider? can_update_conditions?] do
      transitions from: :conditional_offer, to: :conditional_offer
    end

    event :amend_conditions, if: %i[done_by_provider? can_update_conditions?] do
      transitions from: :conditional_offer, to: :conditional_offer
    end
  end
  # rubocop:enable Metrics/BlockLength

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
    self.aasm.events({ permitted: true }, actor).map(&:name)
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
  def self.reject_applications_with_expired_rbd_times
    self.with_rbd_times_in_the_past.pre_offer.each do |application|
      application.reject!('provider')
    end
  end

  def can_update_conditions?(_, provider_code)
    provider_code.in?([self.course.provider.code, self.course.accredited_body.code])
  end
end
