module CandidateInterface
  class GroupedProviderCoursesComponent < ViewComponent::Base
    include ViewHelper

    def initialize(courses_by_provider_and_region:)
      @courses_by_provider_and_region = courses_by_provider_and_region
    end

    def label_for(region_code)
      region_code.present? ? I18n.t("provider_regions.#{region_code}") : I18n.t('provider_regions.no_region_specified')
    end

  private

    attr_reader :courses_by_provider_and_region
  end
end
