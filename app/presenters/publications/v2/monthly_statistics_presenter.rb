module Publications
  module V2
    class MonthlyStatisticsPresenter
      attr_accessor :report

      def initialize(report)
        @report = report.to_h
      end

      def publication_date
        @report.dig(:meta, :publication_date)
      end

      def by_age
        report.dig(:data, :candidate_age_group)
      end

      def by_sex
        report.dig(:data, :candidate_sex)
      end

      def by_phase
        report.dig(:data, :candidate_phase)
      end

      def by_area
        report.dig(:data, :candidate_area)
      end

      def current_reporting_period
        report.dig(:meta, :period)
      end

      def next_cycle_name
        RecruitmentCycle.cycle_name(next_year)
      end

      def current_cycle_name
        RecruitmentCycle.cycle_name
      end

      def current_cycle_verbose_name
        RecruitmentCycle.verbose_cycle_name(current_year)
      end

      def current_cycle?
        current_year == CycleTimetable.current_year
      end

      def next_publication_date
        MonthlyStatisticsTimetable.next_publication_date
      end

      def deferred_applications_count
        report.dig(:data, :candidate_headline_statistics, :deferred_applications_count) || 0
      end

      def previous_year
        current_year - 1
      end

      def next_year
        current_year + 1
      end

      def current_year
        CycleTimetable.current_year(@report.dig(:meta, :generation_date).to_time)
      end
    end
  end
end
