module CandidateInterface
  class MultipleActiveApplicationsContentComponent < ApplicationComponent
    attr_reader :application_form

    delegate :candidate, to: :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def active_previous_application
      # candidate.active_previous_application
      application_form
    end
  end
end
