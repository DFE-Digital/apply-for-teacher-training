module CandidateInterface
  module CourseChoices
    class BlockedSubmissionsController < CandidateInterfaceController
      before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      before_action CarryOverFilter

      def show; end
    end
  end
end
