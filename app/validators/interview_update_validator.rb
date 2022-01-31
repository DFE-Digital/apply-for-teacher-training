class InterviewUpdateValidator < ActiveModel::EachValidator
  def validate(record)
    today = Time.zone.now.beginning_of_day
    old_date = record.date_and_time_change&.first
    new_date = record.date_and_time_change&.second
    rbd_date = record.application_choice.reject_by_default_at

    if old_date.present? && new_date.present? # date_and_time update
      if old_date < today
        record.errors.add :base, 'Changing a past interview'
      elsif new_date < today
        record.errors.add :date_and_time, 'Moving an interview to the past'
      end

      if new_date > rbd_date
        record.errors.add :date_and_time, 'Moving an interview past RBD'
      end
    elsif record.changed? && record.date_and_time < today
      record.errors.add :base, 'Changing a past interview'
    end
  end
end
