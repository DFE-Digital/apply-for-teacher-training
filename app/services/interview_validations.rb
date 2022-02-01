class InterviewValidations
  include ActiveModel::Model

  attr_reader :interview, :today

  validate :interview_is_still_pending, if: -> { interview.changed? }
  validate :date_and_time_changes, if: -> { interview.date_and_time_change }

  def initialize(interview:)
    @interview = interview
    @today = Time.zone.now.beginning_of_day
  end

  def interview_is_still_pending
    if interview.date_and_time < today
      errors.add :base, 'Changing a past interview'
    end
  end

  def date_and_time_changes
    old_date = interview.date_and_time_change&.first
    new_date = interview.date_and_time_change&.second
    rbd_date = interview.application_choice.reject_by_default_at

    if old_date.present? && new_date.present? # date_and_time update
      if old_date < today
        errors.add :base, 'Changing a past interview'
      elsif new_date < today
        errors.add :date_and_time, 'Moving an interview to the past'
      end

      if new_date > rbd_date
        errors.add :date_and_time, 'Moving an interview past RBD'
      end
    end
  end
end
