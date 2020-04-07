module SupportInterface
  class ApplicationMonitor
    def applications_to_disabled_courses
      active_applications.where(
        course_option: CourseOption.joins(:course).where('courses.open_on_apply' => false),
      ).map(&:application_form)
    end

    def applications_to_hidden_courses
      active_applications.where(
        course_option: CourseOption.joins(:course).where('courses.open_on_apply' => true, 'courses.exposed_in_find' => false),
      ).map(&:application_form)
    end

    def applications_to_removed_sites
      active_applications.where(
        course_option: CourseOption.where(invalidated_by_find: true),
      ).map(&:application_form)
    end

    def applications_to_courses_with_sites_without_vacancies
      active_applications.where(
        course_option: CourseOption.where(vacancy_status: 'no_vacancies'),
      ).map(&:application_form)
    end

  private

    def active_applications
      ApplicationChoice.where('status NOT IN (?)', %w[rejected declined withdrawn enrolled conditions_not_met])
    end
  end
end
