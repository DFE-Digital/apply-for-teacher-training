module EndOfCycle
  class ProviderEmailTimetabler
    attr_reader :timetable, :previous_timetable
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

    def send_winter_reject_by_default_reminder_to_providers?
      current_date == winter_reject_by_default_reminder_provider_date
    end

    def winter_reject_by_default_reminder_provider_date
      [].tap do |possible_dates|
        if previous_timetable.winter_reject_by_default_at.present?
          possible_dates << get_weekday(previous_timetable.winter_reject_by_default_at - 2.weeks).to_date
        end
        possible_dates << get_weekday(timetable.winter_reject_by_default_at - 2.weeks).to_date
      end.rfind { |possible_date| possible_date.before?(next_winter_decline_by_default_at) }
    end

  private

    def previous_timetable
      @previous_timetable ||= timetable.relative_previous_timetable
    end

    def next_winter_decline_by_default_at
      if timetable.current_year?
        [].tap do |possible_dates|
          if previous_timetable.winter_decline_by_default_at.present?
            possible_dates << previous_timetable.winter_decline_by_default_at.to_date
          end
          possible_dates << timetable.winter_decline_by_default_at.to_date
        end.find do |possible_date|
          current_date == possible_date || current_date.before?(possible_date)
        end
      else
        timetable.winter_decline_by_default_at
      end
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
