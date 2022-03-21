module Publications
  class MonthlyStatisticsPresenter
    attr_accessor :report

    def initialize(report)
      self.report = report
    end

    delegate :statistics, :deferred_application_count, :month, to: :report

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
      start, finish = MonthlyStatisticsTimetable.reporting_period(report.month)
      "#{start.to_fs(:govuk_date)} to #{finish.to_fs(:govuk_date)}"
    end

    def deferred_applications_count
      report.statistics['deferred_applications_count'] || 0
    end
  end
end
