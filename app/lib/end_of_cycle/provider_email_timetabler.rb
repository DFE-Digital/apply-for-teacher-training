module EndOfCycle
  class ProviderEmailTimetabler
    attr_reader :timetable, :previous_timetable
    delegate_missing_to :timetable

    def send_reject_by_default_reminder_to_providers?
      current_date == reject_by_default_reminder_provider_date
    end

    def reject_by_default_reminder_provider_date
      get_weekday(reject_by_default_at - 2.weeks).to_date
    end

    def send_winter_reject_by_default_reminder_to_providers?
      current_date == winter_reject_by_default_reminder_provider_date
    end

    def winter_reject_by_default_reminder_provider_date
      # We only care about current cycle date AFTER the previous cycle has come to a complete end, eg after the winter decline by default event
      if previous_cycle_closed?
        get_weekday(timetable.winter_reject_by_default_at - 2.weeks).to_date
      else
        get_weekday(previous_timetable.winter_reject_by_default_at - 2.weeks).to_date
      end
    end

  private

    def timetable
      @timetable ||= RecruitmentCycleTimetable.current_timetable
    end

    def previous_timetable
      @previous_timetable ||= timetable.relative_previous_timetable
    end

    def previous_cycle_closed?
      current_date.after? previous_timetable.winter_decline_by_default_at.to_date
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
