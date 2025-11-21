module CandidateInterface
  module References
    class CancelController < BaseController
      skip_before_action ::UnsuccessfulCarryOverFilter
      skip_before_action ::CarryOverFilter
      before_action :set_backlink
      skip_before_action :redirect_to_post_offer_dashboard_if_accepted_deferred_or_recruited
      after_action :verify_authorized
      after_action :verify_policy_scoped

      def new
        authorize @reference, :cancel?, policy_class: ApplicationReferencePolicy

        if @reference&.feedback_requested?
          @application_form = current_application
        else
          redirect_to candidate_interface_application_offer_dashboard_reference_path(@reference)
        end
      end

      def confirm
        authorize @reference, :cancel?, policy_class: ApplicationReferencePolicy

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

      def handle_unauthorised
        flash[:error] = t('candidate_interface.references.not_authorised.must_have_at_least_one_reference')
        redirect_to candidate_interface_application_offer_dashboard_path
      end
    end
  end
end
