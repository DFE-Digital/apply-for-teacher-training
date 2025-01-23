module EndOfCycle
  class CycleJobScheduler
    def initialize(recruitment_cycle_timetable: nil)
      @recruitment_cycle_timetable = recruitment_cycle_timetable || RecruitmentCycleTimetable.current_real_timetable
    end

    def run_decline_by_default?
      Time.zone.now.between?(
        @recruitment_cycle_timetable.decline_by_default,
        @recruitment_cycle_timetable.find_closes,
      )
    end

    def run_reject_by_default?
      Time.zone.now.between?(
        @recruitment_cycle_timetable.reject_by_default,
        @recruitment_cycle_timetable.reject_by_default + 1.day,
      )
    end

    def run_cancel_unsubmitted_applications?
      Time.zone.now.to_date == @recruitment_cycle_timetable.apply_deadline.to_date
    end
  end
end
