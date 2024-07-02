module CandidateInterface
  module References
    class CancelController < BaseController
      skip_before_action ::UnsuccessfulCarryOverFilter
      skip_before_action ::CarryOverFilter
      before_action :set_backlink
      skip_before_action :redirect_v23_applications_to_complete_page_if_submitted_and_not_carried_over
      skip_before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited

      def new
        if @reference&.feedback_requested?
          @application_form = current_application
        else
          redirect_to candidate_interface_application_offer_dashboard_reference_path(@reference)
        end
      end

      def confirm
        if @reference&.feedback_requested?
          CancelReferee.new.call(reference: @reference)
        end

        redirect_to candidate_interface_application_offer_dashboard_path
      end

    private

      def set_backlink
        @back_link = params[:return_to_path] || candidate_interface_application_offer_dashboard_reference_path(@reference)
      end
    end
  end
end
