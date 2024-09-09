module CandidateInterface
  module CourseChoices
    class ReviewInterruptionController < CandidateInterface::CourseChoices::BaseController
      before_action :redirect_to_your_applications_if_submitted

      def show
        @application_choice = current_application.application_choices.find(params[:application_choice_id])
        @word_count = current_application.becoming_a_teacher.scan(/\S+/).size
      end
    end
  end
end
