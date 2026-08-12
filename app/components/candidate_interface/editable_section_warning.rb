module CandidateInterface
  class EditableSectionWarning < ApplicationComponent
    attr_accessor :section_policy, :current_application

    delegate :candidate, :submitted_applications?, to: :current_application
    delegate :active_previous_application, to: :candidate

    def initialize(current_application:, section_policy:)
      @current_application = current_application
      @section_policy = section_policy
    end

    def render?
      submitted_applications? && @section_policy.can_edit?
    end

    def current_recruitment_cycle_year_range
      @current_application.academic_year_range_name
    end

    def previous_recruitment_cycle_year_range
      active_previous_application.academic_year_range_name
    end
  end
end
