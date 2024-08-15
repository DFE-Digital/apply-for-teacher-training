module CandidateInterface
  module CourseChoices
    class ReviewController < CandidateInterface::CourseChoices::BaseController
      skip_before_action CarryOverFilter
      skip_before_action :redirect_to_your_applications_if_cycle_is_over
      skip_before_action :verify_continuous_applications

      def show
        @application_choice = current_application.application_choices.find(params[:application_choice_id])
      end
    end
  end
end
