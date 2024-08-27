class EmailTimetable < CycleTimetable
  def self.send_reject_by_default_reminder_to_providers?
    current_date.to_date == (reject_by_default - 2.weeks).to_date
  end

  def self.send_first_end_of_cycle_reminder_to_candidates?
    current_date.to_date == apply_deadline_first_reminder.to_date
  end

  def self.send_second_end_of_cycle_reminder_to_candidates?
    current_date.to_date == apply_deadline_second_reminder.to_date
  end

  def self.send_find_has_opened_email?
    current_date.to_date == find_opens.to_date
  end

  def self.send_new_cycle_has_started_email?
    current_date.to_date == apply_opens.to_date
  end

  def self.send_application_deadline_has_passed_email_to_candidates?
    current_date.to_date == (apply_deadline + 1.day).to_date
  end

  def self.apply_deadline_second_reminder
    # For 2024, date confirmed is Monday 19 August at 6pm
    (apply_deadline - 1.month).next_weekday
  end

  def self.apply_deadline_first_reminder
    # For 2024, date confirmed is Wednesday 17 July at 6pm
    apply_deadline - 2.months
  end
end
