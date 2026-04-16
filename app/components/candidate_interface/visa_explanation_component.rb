module CandidateInterface
  class VisaExplanationComponent < ApplicationComponent
    attr_reader :application_choice

    def initialize(application_choice)
      @application_choice = application_choice
    end
  end
end
