module CandidateInterface
  module CourseChoices
    class ReviewInterruptionController < CandidateInterface::CourseChoices::BaseController
      before_action :redirect_to_your_applications_if_submitted

      def show
        @application_choice = current_application.application_choices.find(params[:application_choice_id])
        @word_count = current_application.becoming_a_teacher.scan(/\S+/).size
      end

      def continue_without_editing_path
        if application_choice.undergraduate_course_and_application_form_with_degree?
          candidate_interface_course_choices_course_review_undergraduate_interruption_path(application_choice.id)
        elsif current_application.qualifications_enic_reasons_waiting_or_maybe? || current_application.any_qualification_enic_reason_not_needed?
          candidate_interface_course_choices_course_review_enic_interruption_path(@application_choice.id)
        else
          candidate_interface_course_choices_course_review_and_submit_path(@application_choice.id)
        end
      end
      helper_method :continue_without_editing_path
    end
  end
end
