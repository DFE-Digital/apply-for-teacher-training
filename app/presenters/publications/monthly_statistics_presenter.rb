module Publications
  class MonthlyStatisticsPresenter
    attr_accessor :report

    def initialize(report)
      self.report = report
    end

    delegate :statistics, to: :report

    def next_cycle_name
      RecruitmentCycle.cycle_name(CycleTimetable.next_year)
    end

    def current_cycle_verbose_name
      RecruitmentCycle.verbose_cycle_name
    end

    def previous_cycle_verbose_name
      RecruitmentCycle.verbose_cycle_name(RecruitmentCycle.previous_year)
    end

    def current_year
      RecruitmentCycle.current_year
    end

    def previous_year
      RecruitmentCycle.previous_year
    end

    def current_reporting_period
      '12 October 2021 to 22 November 2021'
    end

    def exports
      MonthlyStatisticsTimetable.current_exports
    end
  end
end
