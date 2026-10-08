module CandidateInterface
  module References
    class AcceptOffer::NameController < NameController
      include AcceptOfferConfirmReferences

      def next_path
        candidate_interface_accept_offer_references_email_address_path(
          application_choice,
          @reference&.id || @application_form.application_references.creation_order.last.id,
        )
      end
    end
  end
end
