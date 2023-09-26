module CandidateInterface
  module References
    class AcceptOffer::ReviewController < ReviewController
      include AcceptOfferConfirmReferences

      def destroy
        ApplicationForm.with_unsafe_application_choice_touches do
          @reference.destroy
        end

        redirect_to candidate_interface_accept_offer_path(application_choice)
      end

      def destroy_reference_path
        candidate_interface_accept_offer_destroy_new_reference_path(
          application_choice.id,
          @reference,
        )
      end
      helper_method :destroy_reference_path

    private

      def set_destroy_backlink
        @destroy_backlink = candidate_interface_accept_offer_path(application_choice)
      end
    end
  end
end
