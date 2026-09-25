module CandidateInterface
  module CourseChoices
    class ReviewInterruptionController < CandidateInterface::CourseChoices::BaseController
      before_action :redirect_to_your_applications_if_submitted

      def show
        @application_choice = active_application_choices.find(params.expect(:application_choice_id))
        @word_count = @application_choice.application_form.becoming_a_teacher.scan(/\S+/).size
        @continue_path = ReviewInterruptionPathDecider.decide_path(@application_choice, current_step: :short_personal_statement)
      end
    end
  end
end
