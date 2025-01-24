module EndOfCycle
  class EmailTimetable
    attr_reader :recruitment_cycle_timetable
    delegate_missing_to :recruitment_cycle_timetable

    def initialize(recruitment_cycle_timetable: RecruitmentCycleTimetable.current_real_timetable)
      @recruitment_cycle_timetable = recruitment_cycle_timetable
    end

    def send_reject_by_default_reminder_to_providers?
      reminder_date = get_weekday(reject_by_default - 2.weeks).to_date

      current_date == reminder_date
    end

    def send_reject_by_default_explainer_to_candidates?
      explainer_date = get_weekday(reject_by_default + 1.day).to_date
      current_date == explainer_date
    end

    def send_first_end_of_cycle_reminder_to_candidates?
      current_date == apply_deadline_first_reminder.to_date
    end

    def apply_deadline_first_reminder
      get_weekday(apply_deadline - 2.months)
    end

    def send_second_end_of_cycle_reminder_to_candidates?
      current_date == apply_deadline_second_reminder.to_date
    end

    def apply_deadline_second_reminder
      get_weekday(apply_deadline - 1.month)
    end

    def send_find_has_opened_email?
      current_date == recruitment_cycle_timetable.find_opens.to_date
    end

    def send_new_cycle_has_started_email?
      send_date = get_weekday(apply_opens + 2.days)

      current_date == send_date.to_date
    end

    def send_application_deadline_has_passed_email_to_candidates?
      current_date == (apply_deadline + 1.day).to_date
    end

    def current_date
      Time.zone.now.to_date
    end

  private

    def get_weekday(date)
      return date if date.weekday?

      date.next_weekday
    end
  end
end
