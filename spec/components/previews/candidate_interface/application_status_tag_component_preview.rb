module CandidateInterface
  class ApplicationStatusTagComponentPreview < ViewComponent::Preview
    ApplicationStateChange.valid_states.each do |state_name|
      define_method state_name do
        provider = FactoryBot.build_stubbed(:provider)
        course = FactoryBot.build_stubbed(:course, provider: provider)
        application_choice = FactoryBot.build_stubbed(
          :application_choice,
          status: state_name,
          course_option: FactoryBot.build_stubbed(
            :course_option,
            course: course,
          ),
        )
        render CandidateInterface::ApplicationStatusTagComponent.new(application_choice: application_choice)
      end
    end
  end
end
