module SupportInterface
  class ApplicationMonitor
    def applications_to_disabled_courses
      ApplicationChoice.where(
        course_option: CourseOption.joins(:course).where('courses.open_on_apply' => false),
      ).map(&:application_form)
    end

    def applications_to_hidden_courses
      ApplicationChoice.where(
        course_option: CourseOption.joins(:course).where('courses.open_on_apply' => true, 'courses.exposed_in_find' => false),
      ).map(&:application_form)
    end

    def applications_to_full_courses
      ApplicationChoice.where(
        course_option: CourseOption.where(invalidated_by_find: true),
      ).map(&:application_form)
    end
  end
end
