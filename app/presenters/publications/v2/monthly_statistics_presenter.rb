module Publications
  module V2
    class MonthlyStatisticsPresenter
      attr_reader :statistics
      attr_accessor :report
      delegate :publication_date, :month, :draft?, to: :report

      def initialize(report)
        @report = report
        @statistics = report.statistics.deep_symbolize_keys
      end

      def pre_tda?
        current_year < 2025
      end

      def previous_cycle_url
        return unless current_year == 2024

        'https://www.gov.uk/government/publications/monthly-statistics-on-initial-teacher-training-recruitment-2023-to-2024'
      end

      def first_year_of_continuous_applications?
        current_year == 2024
      end

      def headline_stats
        statistics_data_for(:candidate_headline_statistics, status_merge: true)
      end

      def by_age
        statistics_data_for(:candidate_age_group)
      end

      def by_sex
        statistics_data_for(:candidate_sex)
      end

      def by_area
        statistics_data_for(:candidate_area)
      end

      def by_phase
        statistics_data_for(:candidate_phase)
      end

      def by_route
        statistics_data_for(:candidate_route_into_teaching)
      end

      def by_primary_subject
        statistics_data_for(:candidate_primary_subject)
      end

      def by_secondary_subject
        statistics_data_for(:candidate_secondary_subject)
      end

      def by_provider_region
        statistics_data_for(:candidate_provider_region)
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

      delegate :next_publication_date, to: :MonthlyStatisticsTimetable

      def previous_year
        current_year - 1
      end

      def next_year
        current_year + 1
      end

      def csvs
        statistics.dig(:formats, :csv)
      end

    private

      def statistics_data_for(section_name, status_merge: false)
        section = statistics.dig(:data, section_name)

        return section if status_merge.blank?

        section[:data].each_key do |status|
          section[:data][status].merge!(
            I18n.t("publications.itt_monthly_report_generator.status.#{status}"),
          )
        end

        section[:data].values
      end
    end
  end
end
