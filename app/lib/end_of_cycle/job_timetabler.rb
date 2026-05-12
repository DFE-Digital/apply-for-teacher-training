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

    def winter_rejection_by_default_set?
      !timetable.try(:winter_reject_by_default_at).nil?
    end

    def winter_decline_by_default_set?
      !timetable.try(:winter_decline_by_default_at).nil?
    end

    def run_winter_reject_by_default?
      return false unless winter_rejection_by_default_set?

      previous_timetable = if timetable == RecruitmentCycleTimetable.current_timetable
                             RecruitmentCycleTimetable.previous_timetable
                           else
                             timetable
                           end

      current_time.between?(previous_timetable.winter_reject_by_default_at, previous_timetable.winter_decline_by_default_at)
    end

    def run_winter_decline_by_default?
      return false unless winter_decline_by_default_set?

      previous_timetable = if timetable == RecruitmentCycleTimetable.current_timetable
                             RecruitmentCycleTimetable.previous_timetable
                           else
                             timetable
                           end

      current_time.between?(previous_timetable.winter_decline_by_default_at, previous_timetable.winter_decline_by_default_at + 1.month)
    end

  private

    def current_time
      Time.zone.now
    end
  end
end
