module CandidateInterface
  module CourseChoices
    class GoToFindController < CandidateInterface::CourseChoices::BaseController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action CarryOverFilter

    private

      def current_step
        :go_to_find_explanation
      end

      def step_params
        {}
      end
    end
  end
end
