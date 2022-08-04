module CandidateInterface
  class CompleteReferencesComponent < ViewComponent::Base
    attr_reader :current_application, :section_complete_form

    def initialize(current_application, section_complete_form:)
      @current_application = current_application
      @section_complete_form = section_complete_form
    end

    def render?
      current_application.complete_references_information?
    end
  end
end
