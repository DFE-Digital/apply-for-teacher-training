module SupportInterface
  class LocationStatusComponent < ViewComponent::Base
    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end
  end
end
