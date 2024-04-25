module CandidateInterface
  class GroupedProviderCoursesComponent < ViewComponent::Base
    include ViewHelper

    def label_for(region_code)
      region_code.present? ? I18n.t("provider_regions.#{region_code}") : I18n.t('provider_regions.no_region_specified')
    end

    def courses_grouped_by_provider_and_region
      GetCoursesByProviderAndRegion.call
    end
  end
end
