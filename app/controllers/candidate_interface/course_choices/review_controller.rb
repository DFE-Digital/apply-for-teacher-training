module CandidateInterface
  module CourseChoices
    class ReviewController < CandidateInterface::CourseChoices::BaseController
      def show
        @application_choice = current_application.application_choices.find(params[:application_choice_id])
      end
    end
  end
end
