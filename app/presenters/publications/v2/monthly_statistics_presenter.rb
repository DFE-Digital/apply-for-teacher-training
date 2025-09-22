module Publications
  module V2
    class MonthlyStatisticsPresenter
      attr_reader :statistics
      attr_accessor :report
      delegate :publication_date, :generation_date, :month, :draft?, to: :report

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
        report_timetable.recruitment_cycle_year
      end

      def academic_year_start_month
        "September #{current_year}"
      end

      def academic_year_name
        report_timetable.academic_year_range_name
      end

      def current_cycle_name
        report_timetable.cycle_range_name
      end

      def full_cycle_dates
        "#{report_timetable.find_opens_at.to_fs(:govuk_date)} to #{report_timetable.find_closes_at.to_fs(:govuk_date)}"
      end

      def previous_cycle_name
        previous_timetable.cycle_range_name
      end

      def previous_academic_year_name
        previous_timetable.academic_year_range_name
      end

      def current_cycle_verbose_name
        verbose_cycle_name(current_year)
      end

      def current_cycle?
        report_timetable.current_year?
      end

      def previous_year
        previous_timetable.recruitment_cycle_year
      end

      def next_publication_date
        if next_report_to_be_published.present?
          next_report_to_be_published.publication_date
        else
          monthly_statistics_timetables.next_publication_date
        end
      end

      def next_report_to_be_published
        @next_report_to_be_published ||= Publications::MonthlyStatistics::MonthlyStatisticsReport.drafts.order(:publication_date).first
      end

      def next_year
        next_timetable.recruitment_cycle_year
      end

      def csvs
        statistics.dig(:formats, :csv)
      end

      def report_timetable
        @report_timetable ||= RecruitmentCycleTimetable.find_timetable_by_datetime(statistics.dig(:meta, :generation_date))
      end

      def next_timetable
        @next_timetable ||= report_timetable.relative_next_timetable
      end

      def previous_timetable
        @previous_timetable ||= report_timetable.relative_previous_timetable
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

      def verbose_cycle_name(year)
        "October #{year - 1} to September #{year}"
      end

      def monthly_statistics_timetables
        ::Publications::MonthlyStatistics::Timetable.new
      end
    end
  end
end
