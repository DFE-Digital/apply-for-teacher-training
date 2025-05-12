module EndOfCycle
  class ProviderEmailTimetabler
    attr_reader :timetable
    delegate_missing_to :timetable

    def initialize(timetable: nil)
      @timetable = timetable || RecruitmentCycleTimetable.current_timetable
    end

    def send_reject_by_default_reminder_to_providers?
      current_date == reject_by_default_reminder_provider_date
    end

    def reject_by_default_reminder_provider_date
      get_weekday(reject_by_default_at - 2.weeks).to_date
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
