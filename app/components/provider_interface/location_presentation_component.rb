module ProviderInterface
  class LocationPresentationComponent < ViewComponent::Base
    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def course_option
      application_choice.current_course_option
    end

    delegate :site, to: :course_option

    def site_address_or_name
      address = site.full_address
      address.presence || site.name
    end
  end
end
