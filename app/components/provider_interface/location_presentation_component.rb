module ProviderInterface
  class LocationPresentationComponent < ActionView::Component::Base
    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end

    def site_address_or_name
      address = application_choice.site.full_address
      address.presence || application_choice.site.name
    end
  end
end
