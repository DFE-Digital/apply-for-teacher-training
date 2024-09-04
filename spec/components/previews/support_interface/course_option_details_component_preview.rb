module SupportInterface
  class CourseOptionDetailsComponentPreview < ViewComponent::Preview
    def school_auto_selected
      application_choice = FactoryBot.build_stubbed(:application_choice, school_placement_auto_selected: true)
      course_option = application_choice.current_course_option

      render SupportInterface::CourseOptionDetailsComponent.new(application_choice:, course_option:)
    end

    def school_candidate_selected
      application_choice = FactoryBot.build_stubbed(:application_choice, school_placement_auto_selected: false)
      course_option = application_choice.current_course_option

      render SupportInterface::CourseOptionDetailsComponent.new(application_choice:, course_option:)
    end

    def with_accredited_body
      application_choice = ApplicationChoice.joins(course_option: { course: :accredited_provider }).first
      course_option = application_choice.current_course_option

      render SupportInterface::CourseOptionDetailsComponent.new(application_choice:, course_option:)
    end
  end
end
