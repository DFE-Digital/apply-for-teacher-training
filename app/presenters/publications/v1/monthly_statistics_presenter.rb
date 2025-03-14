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
        next_timetable.cycle_range_name
      end

      def current_cycle_verbose_name
        verbose_cycle_name(current_year)
      end

      def previous_cycle_verbose_name
        verbose_cycle_name(previous_year)
      end

      def first_published_cycle?
        current_year == FIRST_PUBLISHED_CYCLE
      end

      def current_cycle?
        report_timetable.current_year?
      end

      def current_year
        report_timetable.recruitment_cycle_year
      end

      def previous_year
        previous_timetable.recruitment_cycle_year
      end

      def next_year
        next_timetable.recruitment_cycle_year
      end

      delegate :next_publication_date, to: :MonthlyStatisticsTimetable

      def current_reporting_period
        "#{report_timetable.apply_opens_at.to_fs(:govuk_date)} to #{report.generation_date.to_fs(:govuk_date)}"
      end

      def deferred_applications_count
        report.statistics['deferred_applications_count'] || 0
      end

    private

      def report_timetable
        @report_timetable ||= RecruitmentCycleTimetable.find_timetable_by_datetime(@report.generation_date)
      end

      def next_timetable
        @next_timetable ||= report_timetable.relative_next_timetable
      end

      def previous_timetable
        @previous_timetable ||= report_timetable.relative_previous_timetable
      end

      def verbose_cycle_name(year)
        "October #{year - 1} to September #{year}"
      end
    end
  end
end
