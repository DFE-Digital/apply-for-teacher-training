module CandidateInterface
  module CourseChoices
    class ReviewUndergraduateInterruptionController < CandidateInterface::CourseChoices::BaseController
      before_action :redirect_to_your_applications_if_submitted

      def show
        @application_choice = current_application.application_choices.find(params[:application_choice_id])
      end
    end
  end
end
