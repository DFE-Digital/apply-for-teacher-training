module ProviderInterface
  class ApplicationCourseSummaryComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def course_details_school_auto_selected
      application_choice = FactoryBot.build_stubbed(:application_choice, school_placement_auto_selected: true)
      render ApplicationCourseSummaryComponent.new(application_choice:)
    end

    def course_details_school_candidate_selected
      application_choice = FactoryBot.build_stubbed(:application_choice)
      render ApplicationCourseSummaryComponent.new(application_choice:)
    end
  end
end
