require 'csv'

module SupportInterface
  class PerformanceController < SupportInterfaceController
    def index; end

    def course_options
      @course_options = CourseOption
        .where('vacancy_status != ?', 'vacancies')
        .includes(:course, :site)
        .page(params[:page] || 1)
        .per(30)
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

    def unavailable_choices_disabled_courses
      monitor = SupportInterface::ApplicationMonitor.new
      @application_forms = monitor
        .applications_to_disabled_courses
        .page(params[:page] || 1)
        .per(30)
      render(
        :unavailable_choices_detail,
        locals: { title: 'Applications to courses that are no longer available on Apply' },
      )
    end

    def unavailable_choices_hidden_courses
      monitor = SupportInterface::ApplicationMonitor.new
      @application_forms = monitor
        .applications_to_hidden_courses
        .page(params[:page] || 1)
        .per(30)
      render(
        :unavailable_choices_detail,
        locals: { title: 'Applications to courses that have been removed from Find, but were open on Apply' },
      )
    end

    def unavailable_choices_without_vacancies
      monitor = SupportInterface::ApplicationMonitor.new
      @application_forms = monitor
        .applications_to_courses_with_sites_without_vacancies
        .page(params[:page] || 1)
        .per(30)
      render(
        :unavailable_choices_detail,
        locals: { title: 'Applications to courses that no longer have vacancies' },
      )
    end

    def unavailable_choices_removed_sites
      monitor = SupportInterface::ApplicationMonitor.new
      @application_forms = monitor
        .applications_to_hidden_courses
        .page(params[:page] || 1)
        .per(30)
      render(
        :unavailable_choices_detail,
        locals: { title: 'Applications to sites that no longer exist' },
      )
    end
  end
end
