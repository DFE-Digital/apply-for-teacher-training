module CandidateInterface
  module References
    class AcceptOffer::EmailAddressController < EmailAddressController
      include AcceptOfferConfirmReferences

      def next_path
        candidate_interface_accept_offer_references_relationship_path(
          application_choice,
          @reference.id,
        )
      end
    end
  end
end
