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
        # We have delayed the "apply has opened" email in the past to deal with rate limiting from Notify on the first day of applications.
        find_has_opened_announcement_date: find_opens_at.to_date,
        apply_has_opened_announcement_date: (apply_opens_at + 2.days).to_date,
        apply_deadline_first_reminder_date: get_weekday(apply_deadline_at - 2.months).to_date,
        apply_deadline_second_reminder_date: get_weekday(apply_deadline_at - 1.month).to_date,
        application_deadline_has_passed_email_date: (apply_deadline_at + 1.day).to_date,
        reject_by_default_explainer_date: (reject_by_default_at + 1.day).to_date,
        decline_by_default_explainer_date: (decline_by_default_at + 1.day).to_date,
        winter_reject_by_default_explainer_date:,
        winter_decline_by_default_explainer_date:,
      }
    end

    def winter_reject_by_default_explainer_date
      [].tap do |possible_dates|
        possible_dates << (previous_timetable.winter_reject_by_default_at + 1.day).to_date if previous_timetable.winter_reject_by_default_at.present?
        possible_dates << (timetable.winter_reject_by_default_at + 1.day).to_date
      end.rfind do |possible_date|
        possible_date.before?(winter_decline_by_default_explainer_date)
      end
    end

    def winter_decline_by_default_explainer_date
      if timetable.current_year?

        [].tap do |possible_dates|
          possible_dates << (previous_timetable.winter_decline_by_default_at + 1.day).to_date if previous_timetable.winter_decline_by_default_at.present?
          possible_dates << (timetable.winter_decline_by_default_at + 1.day).to_date
        end.find do |possible_date|
          current_date == possible_date || current_date.before?(possible_date)
        end
      else
        (timetable.winter_decline_by_default_at + 1.day).to_date
      end
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

    def send_decline_by_default_explainer?
      current_date == email_schedule.fetch(:decline_by_default_explainer_date)
    end

    def send_winter_reject_by_default_explainer?
      current_date == email_schedule.fetch(:winter_reject_by_default_explainer_date)
    end

    def send_winter_decline_by_default_explainer?
      current_date == email_schedule.fetch(:winter_decline_by_default_explainer_date)
    end

  private

    def previous_timetable
      @previous_timetable ||= timetable.relative_previous_timetable
    end

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
