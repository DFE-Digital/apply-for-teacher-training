module CandidateInterface
  class EditableSectionWarning < ViewComponent::Base
    attr_accessor :editable_section, :current_application

    def initialize(current_application:, editable_section:)
      @current_application = current_application
      @editable_section = editable_section
    end

    def render?
      @current_application.submitted_applications? && @editable_section.can_edit?
    end
  end
end
