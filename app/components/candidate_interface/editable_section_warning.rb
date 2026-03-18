module CandidateInterface
  class EditableSectionWarning < ApplicationComponent
    attr_accessor :section_policy, :current_application

    def initialize(current_application:, section_policy:)
      @current_application = current_application
      @section_policy = section_policy
    end

    def render?
      @current_application.submitted_applications? && @section_policy.can_edit?
    end
  end
end
