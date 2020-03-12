module ProviderInterface
  class ApplicationTimelineComponent < ActionView::Component::Base
    attr_reader :application_choice
    validates :application_choice, presence: true

    def initialize(application_choice:)
      @application_choice = application_choice
    end
  end
end
