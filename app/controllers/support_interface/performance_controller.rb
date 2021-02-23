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
      @dashboard = FeatureMetricsDashboard.last
    end

    def reasons_for_rejection_dashboard
      @reasons_for_rejection = ReasonsForRejectionCountQuery.new.sub_reason_counts
    end

    def reasons_for_rejection_application_choices
      @application_choices = ReasonsForRejectionApplicationsQuery.new(params).call
    end

    def ucas_matches_dashboard; end

    def unavailable_choices
      @monitor = SupportInterface::ApplicationMonitor.new
    end
  end
end
