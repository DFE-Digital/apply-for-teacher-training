module ProviderInterface
  class ApplicationTimelineComponent < ActionView::Component::Base
    def initialize(application_choice:)
      @application_choice = application_choice
    end
  end
end
