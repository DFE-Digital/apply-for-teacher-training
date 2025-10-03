module SupportInterface
  class ApplicationMonitor
    def applications_to_closed_courses
      active_applications
        .joins(application_choices: { course_option: :course })
        .where('courses.application_status' => 'closed')
    end

    def applications_to_hidden_courses
      active_applications
        .joins(application_choices: { course_option: :course })
        .where('courses.exposed_in_find' => false)
    end

    def applications_to_removed_sites
      active_applications
        .where('course_options.site_still_valid' => false)
    end

    def applications_to_courses_with_sites_without_vacancies
      active_applications
        .where('course_options.vacancy_status' => 'no_vacancies')
    end

    def applications_with_mismatched_recruitment_cycle_years
      recruitment_cycle_years = RecruitmentCycleTimetable.years_visible_to_providers

      ApplicationForm
        .where(recruitment_cycle_year: recruitment_cycle_years)
        .includes(%i[candidate application_choices])
        .joins(application_choices: [course_option: [:course]])
        .where('courses.recruitment_cycle_year != application_forms.recruitment_cycle_year')
        .where('application_choices.offer_deferred_at': nil)
        .order('application_forms.id desc')
        .distinct
    end

  private

    def active_applications
      ApplicationForm
        .includes(%i[candidate application_choices])
        .joins(application_choices: [:course_option])
        .where.not(application_choices: { status: ApplicationStateChange::TERMINAL_STATES })
        .order('application_forms.id desc')
        .distinct
    end
  end
end
