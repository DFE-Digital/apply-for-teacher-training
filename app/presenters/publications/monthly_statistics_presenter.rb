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

    def publication_date
      MonthlyStatisticsTimetable.publication_date(report)
    end

    def next_publication_date
      MonthlyStatisticsTimetable.next_publication_date
    end

    def current_reporting_period
      finish_period = MonthlyStatisticsTimetable.third_monday_of_the_month(
        Date.parse("#{report.month}-01"),
      )

      "#{CycleTimetable.apply_opens.to_fs(:govuk_date)} to #{finish_period.to_fs(:govuk_date)}"
    end

    def deferred_applications_count
      report.statistics['deferred_applications_count'] || 0
    end

    def reporting_date_field(date)
      Date.parse("#{date}-01").to_fs(:govuk_date)
    end
  end
end
