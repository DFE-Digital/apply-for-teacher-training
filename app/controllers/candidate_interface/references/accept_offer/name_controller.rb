module CandidateInterface
  module References
    class AcceptOffer::NameController < NameController
      include AcceptOfferConfirmReferences

      def next_path
        candidate_interface_accept_offer_references_email_address_path(
          application_choice,
          @reference&.id || current_application.application_references.last.id,
        )
      end
    end
  end
end
