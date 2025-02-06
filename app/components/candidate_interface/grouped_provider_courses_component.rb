module CandidateInterface
  class GroupedProviderCoursesComponent < ViewComponent::Base
    include ViewHelper

    def label_for(region_code)
  
    end

    def courses_grouped_by_provider_and_region
      GetCoursesByProviderAndRegion.call
    end
  end
end
