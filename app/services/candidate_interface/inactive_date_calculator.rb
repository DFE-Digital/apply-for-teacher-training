module CandidateInterface
  class InactiveDateCalculator
    def initialize(application_choice:, effective_date:, time_limit_calculator: TimeLimitCalculator)
      @application_choice = application_choice
      @time_limit_calculator = time_limit_calculator.new(rule: :reject_by_default, effective_date:)
    end

    def inactive_date
      time_in_future = timetable[:time_in_future]

      return reject_by_default_date if beyond_end_of_cycle_reject_by_default_deadline?(time_in_future) && !HostingEnvironment.sandbox_mode?

      time_in_future
    end

    def inactive_days
      timetable[:days]
    end

    def timetable
      @time_limit_calculator.call
    end

  private

    def beyond_end_of_cycle_reject_by_default_deadline?(time_in_future)
      time_in_future >= reject_by_default_date
    end

    def reject_by_default_date
      @reject_by_default_date ||= 0.business_days.before(
        RecruitmentCycleTimetable.current_timetable.reject_by_default_at.end_of_day,
      )
    end
  end
end
