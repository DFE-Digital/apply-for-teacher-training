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

      def by_area
        report.dig(:data, :candidate_area)
      end

      def by_phase
        report.dig(:data, :candidate_phase)
      end

      def by_route
        report.dig(:data, :candidate_route_into_teaching)
      end

      def by_primary_subject
        report.dig(:data, :candidate_primary_subject)
      end

      def current_reporting_period
        report.dig(:meta, :period)
      end

      def current_year
        CycleTimetable.current_year(@report.dig(:meta, :generation_date).to_time)
      end

      # The Academic year for a given recruitment cycle is effectively the next
      # recruitment cycle. If the report is for 2023-2024 recruitment cycle,
      # the academic year or the year the candidates are applying for is the
      # 2024-2025
      def academic_year_name
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
    end
  end
end
