module CandidateInterface
  module CourseChoices
    class ReviewInterruptionController < CandidateInterface::CourseChoices::BaseController
      before_action :redirect_to_your_applications_if_submitted

      def show
        @application_choice = current_application.application_choices.find(params[:application_choice_id])
        @word_count = current_application.becoming_a_teacher.scan(/\S+/).size
        @continue_path = ReviewInterruptionPathDecider.decide_path(@application_choice, current_step: :short_personal_statement)
      end
    end
  end
end
