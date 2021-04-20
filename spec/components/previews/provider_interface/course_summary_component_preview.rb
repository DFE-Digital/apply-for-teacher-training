module ProviderInterface
  class CourseSummaryComponentPreview < ViewComponent::Preview
    layout 'previews/provider'

    def course_details
      render CourseSummaryComponent.new(course_option: CourseOption.limit(10).sample)
    end
  end
end
