class InterviewValidations
  include ActiveModel::Model

  APPLICATION_STATES_ALLOWING_CHANGES = %w[awaiting_provider_decision interviewing].freeze

  attr_reader :interview, :today

  delegate :provider, to: :interview
  delegate :application_choice, to: :interview
  delegate :current_course, to: :application_choice
  delegate :date_and_time, to: :interview
  delegate :location, to: :interview
  delegate :additional_details, to: :interview
  delegate :cancellation_reason, to: :interview

  validates :date_and_time, presence: true
  validates :application_choice, presence: true
  validates :provider, presence: true
  validates :location, presence: true, word_count: { maximum: 2000 }
  validates :additional_details, word_count: { maximum: 2000 }
  validates :cancellation_reason, word_count: { maximum: 2000 }

  validate :require_training_or_ratifying_provider, if: -> { application_choice && interview.changed? }
  validate :stop_changes_if_interview_already_passed, if: -> { interview.changed? }
  validate :stop_changes_if_interview_already_cancelled, if: -> { interview.changed? }
  validate :stop_changes_if_application_past_interviews_stage, if: -> { application_choice && interview.changed? }
  validate :stop_cancellations_without_a_reason, if: -> { interview.changed? }
  validate :updates_to_date_and_time, if: -> { interview.date_and_time_change }
  validate :keep_date_and_time_before_rbd, if: -> { interview.date_and_time_change }

  def initialize(interview:)
    @interview = interview
    @today = Time.zone.now.beginning_of_day
  end

  def rbd_date
    @rbd_date ||= application_choice&.reject_by_default_at
  end

  def require_training_or_ratifying_provider
    ratifying = current_course.accredited_provider
    ratifying_provider_check = ratifying ? provider == ratifying : false

    unless provider == current_course.provider || ratifying_provider_check
      errors.add :provider, 'Provider must be training or ratifying provider'
    end
  end

  def stop_changes_if_interview_already_passed
    if date_and_time && date_and_time < today
      errors.add :base, 'Changing a past interview'
    end
  end

  def stop_changes_if_interview_already_cancelled
    old_cancelled_at = interview.cancelled_at_change&.first

    if old_cancelled_at.present?
      errors.add :base, 'Changing a cancelled interview'
    end
  end

  def stop_changes_if_application_past_interviews_stage
    unless APPLICATION_STATES_ALLOWING_CHANGES.include?(application_choice.status)
      errors.add :application_choice, 'Application is past interviews stage'
    end
  end

  def stop_cancellations_without_a_reason
    if interview.cancelled_at && interview.cancellation_reason.blank?
      errors.add :cancellation_reason, 'Cancellation reason is required'
    end
  end

  def updates_to_date_and_time
    old_date = interview.date_and_time_change&.first
    new_date = interview.date_and_time_change&.second

    if old_date.present? && new_date.present?
      if old_date < today
        errors.add :base, 'Changing a past interview'
      elsif new_date < today
        errors.add :date_and_time, 'Moving an interview to the past'
      end
    end
  end

  def keep_date_and_time_before_rbd
    if rbd_date && date_and_time > rbd_date
      errors.add :date_and_time, 'Scheduling an interview past RBD'
    end
  end
end
