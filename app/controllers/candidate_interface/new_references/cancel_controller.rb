module CandidateInterface
  module NewReferences
    class CancelController < BaseController
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
    end
  end
end
