require 'csv'

module SupportInterface
  class PerformanceController < SupportInterfaceController
    def index; end

    def course_options
      @course_options = CourseOption.where('vacancy_status != ?', 'vacancies').includes(:course, :site)
    end

    def courses_dashboard; end

    def service_performance_dashboard
      year = params[:year] if %w[2020 2021].include?(params[:year])

      @statistics = PerformanceStatistics.new(year)
    end

    def feature_metrics_dashboard
      @reference_statistics = ReferenceFeatureMetrics.new
      @work_history_statistics = WorkHistoryFeatureMetrics.new
      @magic_link_statistics = MagicLinkFeatureMetrics.new
      @reasons_for_rejection_statistics = ReasonsForRejectionFeatureMetrics.new
    end

    def reasons_for_rejection_dashboard
      @reasons_for_rejection = ReasonsForRejectionCountQuery.new.sub_reason_counts
    end

    def ucas_matches_dashboard; end

    def unavailable_choices
      @monitor = SupportInterface::ApplicationMonitor.new
    end
  end
end
