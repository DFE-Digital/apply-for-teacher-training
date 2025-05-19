module CandidateInterface
  module CourseChoices
    class ReviewUndergraduateInterruptionController < CandidateInterface::CourseChoices::BaseController
      before_action :redirect_to_your_applications_if_submitted

      def show
        @application_choice = current_application.application_choices.find(params[:application_choice_id])
        @continue_without_editing_path = ReviewInterruptionPathDecider.decide_path(
          @application_choice,
          current_step: :undergraduate_course_with_degree,
        )
      end
    end
  end
end
