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
      "#{CycleTimetable.apply_opens.to_s(:govuk_date)} to #{report.created_at.to_s(:govuk_date)}"
    end

    def exports
      MonthlyStatisticsTimetable.current_exports
    end

    def deferred_applications_count
      report.statistics['deferred_applications_count'] || 0
    end
  end
end
