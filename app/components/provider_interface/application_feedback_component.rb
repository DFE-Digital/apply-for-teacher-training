module ProviderInterface
  class ApplicationFeedbackComponent < ApplicationComponent
    attr_reader :application_choice

    def initialize(application_choice:)
      @application_choice = application_choice
    end
  end
end
