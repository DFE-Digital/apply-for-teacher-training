module CandidateInterface
  module References
    class AcceptOffer::ReferencesInterruptionsController < InterruptionsController
      include AcceptOfferConfirmReferences

      def set_navigation_links
        @next_step = return_to_path || candidate_interface_accept_offer_references_relationship_path(
          application_choice,
          @reference.id,
        )

        return_to_params = return_to_offer? ? { return_to: 'accept-offer' } : nil

        @back_link = candidate_interface_accept_offer_references_edit_email_address_path(
          application_choice,
          @reference.id,
          params: return_to_params,
        )
      end
    end
  end
end
