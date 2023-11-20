module Publications
  module V2
    class MonthlyStatisticsPresenter
      attr_reader :month, :statistics
      attr_accessor :report

      def initialize(report)
        @month = report.month
        @report = report
        @statistics = report.statistics.deep_symbolize_keys
      end

      def publication_date
        @report.publication_date
      end

      def headline_stats
        statistics.dig(:data, :candidate_headline_statistics)[:data]
          .deep_merge(I18n.t('publications.itt_monthly_report_generator.status'))
          .values
      end

      def by_age
        statistics.dig(:data, :candidate_age_group)
      end

      def by_sex
        statistics.dig(:data, :candidate_sex)
      end

      def by_area
        statistics.dig(:data, :candidate_area)
      end

      def by_phase
        statistics.dig(:data, :candidate_phase)
      end

      def by_route
        statistics.dig(:data, :candidate_route_into_teaching)
      end

      def by_primary_subject
        statistics.dig(:data, :candidate_primary_subject)
      end

      def by_secondary_subject
        statistics.dig(:data, :candidate_secondary_subject)
      end

      def by_provider_region
        statistics.dig(:data, :candidate_provider_region)
      end

      def current_reporting_period
        statistics.dig(:meta, :period)
      end

      def current_year
        CycleTimetable.current_year(statistics.dig(:meta, :generation_date).to_time)
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
        statistics.dig(:data, :candidate_headline_statistics, :deferred_applications_count) || 0
      end

      def previous_year
        current_year - 1
      end

      def next_year
        current_year + 1
      end

      def csvs
        statistics.dig(:formats, :csv)
      end
    end
  end
end
