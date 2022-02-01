class InterviewValidations
  include ActiveModel::Model

  attr_reader :interview, :today

  delegate :date_and_time, to: :interview
  delegate :application_choice, to: :interview

  validates :date_and_time, presence: true
  validates :application_choice, presence: true

  validate :stop_changes_if_interview_already_passed, if: -> { interview.changed? }
  validate :updates_to_date_and_time, if: -> { interview.date_and_time_change }
  validate :keep_date_and_time_before_rbd, if: -> { interview.date_and_time_change }

  def initialize(interview:)
    @interview = interview
    @today = Time.zone.now.beginning_of_day
  end

  def rbd_date
    @rbd_date ||= application_choice.reject_by_default_at
  end

  def stop_changes_if_interview_already_passed
    if date_and_time && date_and_time < today
      errors.add :base, 'Changing a past interview'
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
    if date_and_time > rbd_date
      errors.add :date_and_time, 'Scheduling an interview past RBD'
    end
  end
end
