module CandidateInterface
  module CourseChoices
    class ReviewReferencesInterruptionController < CandidateInterface::CourseChoices::BaseController
      before_action :redirect_to_your_applications_if_submitted

      def show
        @application_choice = current_application.application_choices.find(params.require(:application_choice_id))
        @continue_without_editing_path = ReviewInterruptionPathDecider.decide_path(
          @application_choice,
          current_step: :references_with_personal_email_addresses,
        )
      end
    end
  end
end
