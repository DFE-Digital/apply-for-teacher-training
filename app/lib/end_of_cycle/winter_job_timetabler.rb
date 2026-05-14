module EndOfCycle
  class WinterJobTimetabler
    attr_reader :timetable
    delegate_missing_to :timetable

    def initialize(timetable: nil)
      @timetable = timetable || RecruitmentCycleTimetable.previous_timetable
    end

    def winter_rejection_by_default_set?
      timetable.try(:winter_reject_by_default_at).present?
    end

    def winter_decline_by_default_set?
      timetable.try(:winter_decline_by_default_at).present?
    end

    def run_winter_reject_by_default?
      return false unless winter_rejection_by_default_set?

      current_time.between?(timetable.winter_reject_by_default_at, timetable.winter_decline_by_default_at)
    end

    def run_winter_decline_by_default?
      return false unless winter_decline_by_default_set?

      current_time.between?(timetable.winter_decline_by_default_at, timetable.winter_decline_by_default_at + 1.month)
    end

    def run_winter_cancel_reference_requests?
      run_winter_decline_by_default?
    end

  private

    def current_time
      Time.zone.now
    end
  end
end
