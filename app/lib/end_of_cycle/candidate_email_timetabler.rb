module EndOfCycle
  class CandidateEmailTimetabler
    attr_reader :timetable
    delegate_missing_to :timetable

    def self.email_schedule(email_date)
      new.email_schedule.fetch(email_date)
    end

    def initialize(timetable: nil)
      @timetable = timetable || RecruitmentCycleTimetable.current_timetable
    end

    def email_schedule
      {
        # All dates should be reviewed as part of end-of / start-of cycle planning
        apply_deadline_first_reminder_date: get_weekday(apply_deadline_at - 2.months).to_date,
        apply_deadline_second_reminder_date: get_weekday(apply_deadline_at - 1.month).to_date,
        application_deadline_has_passed_email_date: (apply_deadline_at + 1.day).to_date,
        reject_by_default_explainer_date: (reject_by_default_at + 1.day).to_date,
        find_has_opened_announcement_date: find_opens_at.to_date,
        # We have delayed the "apply has opened" email in the past to deal with rate limiting from Notify on the first day of applications.
        apply_has_opened_announcement_date: (apply_opens_at + 2.days).to_date,
      }
    end

    def send_first_end_of_cycle_reminder?
      current_date == email_schedule.fetch(:apply_deadline_first_reminder_date)
    end

    def send_second_end_of_cycle_reminder?
      current_date == email_schedule.fetch(:apply_deadline_second_reminder_date)
    end

    def send_find_has_opened_email?
      current_date == email_schedule.fetch(:find_has_opened_announcement_date)
    end

    def send_new_cycle_has_started_email?
      current_date == email_schedule.fetch(:apply_has_opened_announcement_date)
    end

    def send_application_deadline_has_passed_email?
      current_date == email_schedule.fetch(:application_deadline_has_passed_email_date)
    end

    def send_reject_by_default_explainer?
      current_date == email_schedule.fetch(:reject_by_default_explainer_date)
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
