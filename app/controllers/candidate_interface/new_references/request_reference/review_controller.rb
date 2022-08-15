module CandidateInterface
  module NewReferences
    class RequestReference::ReviewController < ReviewController
      include RequestReferenceOfferDashboard
      before_action :set_reference, :set_policy
      before_action :verify_reference_can_be_requested, only: %i[request_feedback]

      def request_feedback
        ::RequestReference.new.call(@reference)
        flash[:success] = "Reference request sent to #{@reference.name}"

        redirect_to candidate_interface_application_offer_dashboard_path
      end

    private

      def verify_reference_can_be_requested
        render_404 and return unless @policy.can_request?
      end

      def set_reference
        @reference = current_application.application_references.find(params[:id])
      end

      def set_policy
        @policy = ReferenceActionsPolicy.new(@reference)
      end
    end
  end
end
