module CandidateInterface
  class PreviousApplicationsComponent < ViewComponent::Base
    include ViewHelper

    def initialize(candidate:)
      @candidate = candidate
    end

    def render?
      application_choices.present?
    end

    def application_choices
      (previous_application_choices + eligible_current_application_choices)
        .compact
        .sort_by(&:id)
        .reverse
    end

    def provider_name_for(application_choice)
      application_choice
        .provider
        .name
    end

    def course_name_and_code_for(application_choice)
      application_choice.course.name_and_code
    end

  private

    def eligible_current_application_choices
      if application_choice_has_accepted_state_present?
        # Reject all applications that have an ACCEPTED_STATE
        # These will appear in the CandidateInterface::CourseChoicesReview component
        application_choices_without_accepted_states
      else
        []
      end
    end

    def application_choices_without_accepted_states
      current_application_choices
        .reject { |ac| ApplicationStateChange::ACCEPTED_STATES.include?(ac.status.to_sym) }
    end

    def application_choice_has_accepted_state_present?
      current_application_choices.any? { |ac| ApplicationStateChange::ACCEPTED_STATES.include?(ac.status.to_sym) }
    end

    def current_application_choices
      @candidate
        .current_application
        .application_choices
        .includes(:course, :provider)
        .all
    end

    def previous_application_choices
      previous_application_forms = @candidate.application_forms.all - [@candidate.current_application]

      if previous_application_forms
        previous_application_forms
          .map { |af| af.application_choices.includes(:course, :provider) }
          .flatten
      else
        []
      end
    end
  end
end
