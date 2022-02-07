module CandidateInterface
  class ApplyAgainAddAnotherCourseComponentPreview < ViewComponent::Preview
    def with_one_course_choice
      application_choice = FactoryBot.build_stubbed(:application_choice)
      application_form = FactoryBot.build_stubbed(:application_form, application_choices: [application_choice])
      render ApplyAgainAddAnotherCourseComponent.new(application_form: application_form)
    end

    def with_two_course_choices
      application_choice = FactoryBot.build_stubbed(:application_choice)
      second_application_choice = FactoryBot.build_stubbed(:application_choice)
      application_form = FactoryBot.build_stubbed(:application_form, application_choices: [application_choice, second_application_choice])
      render ApplyAgainAddAnotherCourseComponent.new(application_form: application_form)
    end
  end
end
