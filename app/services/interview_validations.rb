class InterviewValidations
  include ActiveModel::Model

  APPLICATION_STATES_ALLOWING_CHANGES = ApplicationStateChange::INTERVIEWABLE_STATES.map(&:to_s).freeze

  attr_reader :interview, :today

  delegate :current_course, to: :application_choice
  delegate :application_choice, :provider, :date_and_time, :location,
           :additional_details, :cancellation_reason, to: :interview

  validates :date_and_time, :application_choice, :provider, :location, presence: true
  validates :location, :additional_details, :cancellation_reason, length: { maximum: 10240 }

  validate :require_training_or_ratifying_provider, if: -> { application_choice && interview.changed? }
  validate :stop_new_interviews_in_the_past, if: -> { interview.changed? }
  validate :stop_changes_if_interview_in_the_past, if: -> { interview.changed? }
  validate :stop_changes_if_interview_already_cancelled, if: -> { interview.changed? }
  validate :stop_changes_if_application_past_interviews_stage, if: -> { application_choice && interview.changed? }
  validate :stop_cancellations_without_a_reason, if: -> { interview.changed? }
  validate :check_updates_to_date_and_time, if: -> { interview.date_and_time_change }
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

    unless provider == current_course.provider || ratifying_provider_check || provider.blank?
      errors.add :provider, :training_or_ratifying_only
    end
  end

  def stop_new_interviews_in_the_past
    if !interview.date_and_time_was && date_and_time && date_and_time < today
      errors.add :date_and_time, :in_the_past
    end
  end

  def stop_changes_if_interview_in_the_past
    old_date = interview.date_and_time_was

    if old_date.present? && old_date < today
      errors.add :base, :changing_a_past_interview
    end
  end

  def stop_changes_if_interview_already_cancelled
    old_cancelled_at = interview.cancelled_at_was

    if old_cancelled_at.present?
      if interview.cancelled_at == old_cancelled_at
        errors.add :base, :changing_a_cancelled_interview
      else
        errors.add :base, :cancelling_a_cancelled_interview
      end
    end
  end

  def stop_changes_if_application_past_interviews_stage
    unless APPLICATION_STATES_ALLOWING_CHANGES.include?(application_choice.status)
      errors.add :application_choice, :status_past_interviewing_stage
    end
  end

  def stop_cancellations_without_a_reason
    if interview.cancelled_at && interview.cancellation_reason.blank?
      errors.add :cancellation_reason, :blank
    end
  end

  def check_updates_to_date_and_time
    old_date = interview.date_and_time_change&.first
    new_date = interview.date_and_time_change&.second

    if old_date.present? && new_date.present?
      if new_date < today && old_date >= today
        errors.add :date_and_time, :moving_interview_to_the_past
      elsif new_date < today
        errors.add :date_and_time, :in_the_past
      end
    end
  end

  def keep_date_and_time_before_rbd
    if rbd_date && date_and_time > rbd_date
      errors.add :date_and_time, :past_rbd_date
    end
  end
end
