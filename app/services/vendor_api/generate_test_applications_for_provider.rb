module VendorAPI
  class GenerateTestApplicationsForProvider
    def call(provider:, courses_per_application:, count:, for_ratified_courses: false)
      raise ParameterInvalid, 'Parameter is invalid (cannot be zero): courses_per_application' if courses_per_application.zero?

      course_ids = course_list_for_provider(provider, for_ratified_courses).pluck(:id)

      raise ParameterInvalid, 'Parameter is invalid (cannot be greater than number of available courses): courses_per_application' if course_ids.count < courses_per_application

      GenerateTestApplicationsForCourses.perform_async(course_ids, courses_per_application, count)
    end

  private

    def course_list_for_provider(provider, for_ratified_courses)
      if for_ratified_courses
        GetCoursesRatifiedByProvider.call(provider: provider)
      else
        Course.current_cycle
              .open_on_apply
              .joins(:course_options)
              .distinct
              .where(provider: provider)
      end
    end
  end
end
