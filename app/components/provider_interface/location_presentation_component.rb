module ProviderInterface
  class LocationPresentationComponent < ViewComponent::Base
    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def course_option
      application_choice.offered_course_option || application_choice.course_option
    end

    def site
      course_option.site
    end

    def site_address_or_name
      address = site.full_address
      address.presence || site.name
    end
  end
end
