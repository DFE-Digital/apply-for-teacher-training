module CandidateInterface
  module CourseChoices
    class GoToFindController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action CarryOverFilter

      def new
        @wizard = CourseChoices::CourseSelectionWizard.new(current_step:)
      end

    private

      def current_step
        :go_to_find_explanation
      end
    end
  end
end
