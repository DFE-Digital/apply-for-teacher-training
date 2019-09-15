class CandidateApplication < ApplicationRecord
  include AASM

  belongs_to :course, optional: true

  scope :with_rbd_times_in_the_past, -> { where('rejected_by_default_at < ?', Time.now) }
  scope :pre_offer, -> { where(state: %i[unsubmitted references_pending application_complete]) }

  # rubocop:disable Metrics/BlockLength
  aasm column: 'state' do
    before_all_events :authorize

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
      transitions from: :unsubmitted, to: :references_pending
    end

    event :submit_reference do
      transitions from: :references_pending, to: :application_complete
    end

    event :make_conditional_offer do
      transitions from: :application_complete, to: :conditional_offer
    end

    event :make_unconditional_offer do
      transitions from: :application_complete, to: :unconditional_offer
    end

    event :accept_offer do
      transitions from: :conditional_offer, to: :meeting_conditions
      transitions from: :unconditional_offer, to: :recruited
    end

    event :confirm_conditions_met do
      transitions from: :meeting_conditions, to: :recruited
    end

    event :confirm_onboarding do
      transitions from: :recruited, to: :enrolled
    end

    event :reject do
      transitions from: %i[references_pending application_complete conditional_offer unconditional_offer meeting_conditions], to: :rejected
    end

    event :add_conditions do
      transitions from: :conditional_offer, to: :conditional_offer
    end

    event :amend_conditions do
      transitions from: :conditional_offer, to: :conditional_offer
    end
  end
  # rubocop:enable Metrics/BlockLength

  def authorize(user, *_args)
    Pundit.authorize(user, self, "#{aasm.current_event.to_s.gsub('!', '')}?".to_sym)
  rescue Pundit::NotAuthorizedError
    raise AASM::InvalidTransition.new(self, aasm.current_event, :default)
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
end
