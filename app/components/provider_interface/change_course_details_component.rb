module ProviderInterface
  class ChangeCourseDetailsComponent < CourseDetailsComponent
    def change_provider_path
      available_providers.length > 1 ? edit_provider_interface_application_choice_course_providers_path(application_choice) : nil
    end
  end
end
