module CandidateInterface
  class ReferencesComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form:)
      @application_form = application_form
    end

    def references
      application_form.application_references
    end
  end
end
