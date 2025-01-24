module EndOfCycle
  class JobsTimetable
    attr_reader :recruitment_cycle_timetable
    delegate_missing_to :recruitment_cycle_timetable

    def initialize(recruitment_cycle_timetable: RecruitmentCycleTimetable.current_real_timetable)
      @recruitment_cycle_timetable = recruitment_cycle_timetable
    end

    def run_decline_by_default?
      current_date.between?(decline_by_default, find_closes)
    end

    def run_reject_by_default?
      current_date.between?(reject_by_default, reject_by_default + 1.day)
    end

    def run_cancel_unsubmitted_applications?
      current_date.to_date == apply_deadline.to_date
    end

    def current_date
      Time.zone.now
    end
  end
end
