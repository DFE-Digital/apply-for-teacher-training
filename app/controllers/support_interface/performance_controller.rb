require 'csv'

module SupportInterface
  class PerformanceController < SupportInterfaceController
    REASONS_FOR_REJECTION_RECRUITMENT_CYCLE_YEAR = 2023

    def index; end

    def course_options
      @course_options = CourseOption
        .where.not('vacancy_status = ?', 'vacancies')
        .includes(:course, :site)

      @pagy, @course_options = pagy(@course_options, items: 30)
    end

    def courses_dashboard; end

    def service_performance_dashboard
      year = params[:year] if RecruitmentCycle.years_visible_in_support.include?(params[:year].to_i)

      @statistics = PerformanceStatistics.new(year)
    end

    def reasons_for_rejection_dashboard
      return render_404 unless year_param.to_i >= REASONS_FOR_REJECTION_RECRUITMENT_CYCLE_YEAR

      query = ReasonsForRejectionCountQuery.new(year_param)
      @reasons_for_rejection = query.subgrouped_reasons
      @total_structured_rejection_reasons_count = query.total_structured_reasons_for_rejection
      @total_structured_rejection_reasons_count_this_month = query.total_structured_reasons_for_rejection(time_period: :this_month)
      @recruitment_cycle_year = year_param.to_i
    end

    def reasons_for_rejection_application_choices
      @application_choices = ReasonsForRejectionApplicationsQuery.new(params.with_defaults(page: 1)).call
      @recruitment_cycle_year = params.fetch(:recruitment_cycle_year, RecruitmentCycle.current_year).to_i
    end

    def unavailable_choices
      redirect_to support_interface_unavailable_choices_closed_courses_path
    end

    def unavailable_choices_closed_courses
      unavailable_choices_detail(
        :applications_to_closed_courses,
        'Applications to courses that are closed by provider',
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
      @application_forms = @monitor.send(category)
      @pagy, @application_forms = pagy(@application_forms, items: 30)

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
