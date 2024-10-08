module CandidateInterface
  class ContinueWithoutEditing < ViewComponent::Base
    attr_reader :current_application, :application_choice

    def initialize(current_application:, application_choice:)
      @current_application = current_application
      @application_choice = application_choice
    end

    def continue_without_editing
      if application_choice.undergraduate_course_and_application_form_with_degree?
        candidate_interface_course_choices_course_review_undergraduate_interruption_path(application_choice.id)
      elsif current_application.qualifications_enic_reasons_waiting_or_maybe? || current_application.any_qualification_enic_reason_not_needed?
        candidate_interface_course_choices_course_review_enic_interruption_path(@application_choice.id)
      else
        candidate_interface_course_choices_course_review_and_submit_path(@application_choice.id)
      end
    end
  end
end
