module CandidateInterface
  class MultipleActiveApplicationsContentComponent < ApplicationComponent
    attr_reader :application_form

    delegate :candidate, to: :application_form
    delegate :active_previous_application, to: :candidate

    def initialize(application_form:)
      @application_form = application_form
    end

    def render?
      active_previous_application.present?
    end
  end
end
