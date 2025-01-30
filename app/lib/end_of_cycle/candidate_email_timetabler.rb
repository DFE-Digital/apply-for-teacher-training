module EndOfCycle
  class CandidateEmailTimetabler
    attr_reader :timetable
    delegate_missing_to :timetable

    def initialize(timetable: nil)
      @timetable = timetable || RecruitmentCycleTimetable.current_timetable
    end

    def apply_deadline_first_reminder_date
      get_weekday(apply_deadline_at - 2.months).to_date
    end

    def send_first_end_of_cycle_reminder?
      current_date == apply_deadline_first_reminder_date
    end

    def send_second_end_of_cycle_reminder?
      current_date == apply_deadline_second_reminder_date
    end

    def apply_deadline_second_reminder_date
      get_weekday(apply_deadline_at - 1.month).to_date
    end

    def send_find_has_opened_email?
      current_date == find_has_opened_email_date
    end

    def find_has_opened_email_date
      find_opens_at.to_date
    end

    def send_new_cycle_has_started_email?
      current_date == new_cycle_has_started_email_date
    end

    def new_cycle_has_started_email_date
      (apply_opens_at + 2.days).to_date
    end

    def send_application_deadline_has_passed_email?
      current_date == application_deadline_has_passed_email_date
    end

    def application_deadline_has_passed_email_date
      (apply_deadline_at + 1.day).to_date
    end

    def send_reject_by_default_explainer?
      current_date == reject_by_default_explainer_date
    end

    def reject_by_default_explainer_date
      (reject_by_default_at + 1.day).to_date
    end

  private

    def current_date
      Time.zone.now.to_date
    end

    def get_weekday(date)
      if date.weekday?
        date
      else
        date.next_weekday
      end
    end
  end
end
