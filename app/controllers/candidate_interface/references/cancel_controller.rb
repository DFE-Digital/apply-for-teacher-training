module CandidateInterface
  module References
    class CancelController < BaseController
      before_action :set_backlink
      skip_before_action :redirect_to_dashboard_if_submitted

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
        @back_link = return_to_path || candidate_interface_application_offer_dashboard_reference_path(@reference)
      end

      def return_to_path
        candidate_interface_application_offer_dashboard_path if params[:return_to] == 'offer-dashboard'
      end
    end
  end
end
