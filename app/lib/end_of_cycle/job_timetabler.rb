module EndOfCycle
  class JobTimetabler
    attr_reader :timetable
    delegate_missing_to :timetable

    def initialize(timetable: nil)
      @timetable = timetable || RecruitmentCycleTimetable.current_timetable
    end

    def run_cancel_unsubmitted_applications?
      current_time.between?(apply_deadline_at, reject_by_default_at)
    end

    def run_reject_by_default?
      current_time.between?(reject_by_default_at, decline_by_default_at)
    end

    def run_decline_by_default?
      current_time.between?(decline_by_default_at, find_closes_at)
    end

  private

    def current_time
      Time.zone.now
    end
  end
end
