module EndOfCycle
  class JobTimetabler
    attr_reader :timetable
    delegate_missing_to :timetable

    def initialize(timetable: nil)
      @timetable = timetable || RecruitmentCycleTimetable.current_timetable
    end

    def run_reject_by_default?
      current_time.between?(reject_by_default_at, reject_by_default_at + 1.day)
    end

    def cancel_unsubmitted_applications?
      current_date == apply_deadline_at.to_date
    end

    def run_decline_by_default?
      current_date.between?(decline_by_default_at, find_closes_at)
    end

  private

    def current_time
      Time.zone.now
    end

    def current_date
      Time.zone.now.to_date
    end
  end
end
