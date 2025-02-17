module Publications
  module V1
    class MonthlyStatisticsPresenter
      FIRST_PUBLISHED_CYCLE = 2022

      attr_accessor :report

      def initialize(report)
        @report = report
      end

      delegate :publication_date, :statistics, :deferred_application_count, :month, to: :report

      def next_cycle_name
        RecruitmentCycle.cycle_name(next_year)
      end

      def current_cycle_verbose_name
        RecruitmentCycle.verbose_cycle_name(current_year)
      end

      def previous_cycle_verbose_name
        RecruitmentCycle.verbose_cycle_name(previous_year)
      end

      def first_published_cycle?
        current_year == FIRST_PUBLISHED_CYCLE
      end

      def current_cycle?
        current_year == CycleTimetable.current_year
      end

      def current_year
        CycleTimetable.current_year(@report.generation_date.to_time)
      end

      def previous_year
        current_year - 1
      end

      def next_year
        current_year + 1
      end

      delegate :next_publication_date, to: :MonthlyStatisticsTimetable

      def current_reporting_period
        "#{CycleTimetable.apply_opens(current_year).to_fs(:govuk_date)} to #{report.generation_date.to_fs(:govuk_date)}"
      end

      def deferred_applications_count
        report.statistics['deferred_applications_count'] || 0
      end
    end
  end
end
