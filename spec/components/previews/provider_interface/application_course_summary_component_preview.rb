module ProviderInterface
  class ApplicationCourseSummaryComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def course_details
      application_choice = FactoryBot.build_stubbed(:application_choice)
      render ApplicationCourseSummaryComponent.new(application_choice:)
    end
  end
end
