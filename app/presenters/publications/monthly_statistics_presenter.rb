module Publications
  class MonthlyStatisticsPresenter
    attr_accessor :report

    def initialize(report)
      self.report = report
    end

    def statistics
      report.statistics
    end

    def next_cycle_name
      RecruitmentCycle.cycle_name(CycleTimetable.next_year)
    end

    def current_cycle_verbose_name
      RecruitmentCycle.verbose_cycle_name
    end

    def current_year
      RecruitmentCycle.current_year
    end

    def exports
      MonthlyStatisticsTimetable.current_exports
    end
  end
end
