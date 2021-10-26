require 'csv'

module SupportInterface
  class PerformanceController < SupportInterfaceController
    def index; end

    def course_options
      @course_options = CourseOption
        .where.not('vacancy_status = ?', 'vacancies')
        .includes(:course, :site)
        .page(params[:page] || 1)
        .per(30)
    end

    def courses_dashboard; end

    def service_performance_dashboard
      year = params[:year] if %w[2020 2021 2022].include?(params[:year])

      @statistics = PerformanceStatistics.new(year)
    end

    def feature_metrics_dashboard
      @dashboard = FeatureMetricsDashboard.last
    end

    def reasons_for_rejection_dashboard
      render_404 unless RecruitmentCycle::CYCLES.keys.include?(year_param.to_s)

      query = ReasonsForRejectionCountQuery.new(year_param)
      @reasons_for_rejection = query.sub_reason_counts
      @total_structured_rejection_reasons_count = query.total_structured_reasons_for_rejection
    end

    def reasons_for_rejection_application_choices
      @application_choices = ReasonsForRejectionApplicationsQuery.new(params).call
    end

    def unavailable_choices
      redirect_to support_interface_unavailable_choices_disabled_courses_path
    end

    def unavailable_choices_disabled_courses
      unavailable_choices_detail(
        :applications_to_disabled_courses,
        'Applications to courses that are no longer available on Apply',
      )
    end

    def unavailable_choices_hidden_courses
      unavailable_choices_detail(
        :applications_to_hidden_courses,
        'Applications to courses removed from Find, but open on Apply',
      )
    end

    def unavailable_choices_without_vacancies
      unavailable_choices_detail(
        :applications_to_courses_with_sites_without_vacancies,
        'Applications to courses that no longer have vacancies',
      )
    end

    def unavailable_choices_removed_sites
      unavailable_choices_detail(
        :applications_to_hidden_courses,
        'Applications to sites that no longer exist',
      )
    end

  private

    def unavailable_choices_detail(category, title)
      @monitor = SupportInterface::ApplicationMonitor.new
      @application_forms = @monitor
        .send(category)
        .page(params[:page] || 1)
        .per(30)
      render(
        :unavailable_choices_detail,
        locals: { title: title },
      )
    end

    def year_param
      params.fetch(:year, RecruitmentCycle.current_year)
    end
  end
end
