module CandidateInterface
  module NewReferences
    class AcceptOffer::EmailAddressController < EmailAddressController
      include AcceptOfferConfirmReferences

      def next_path
        candidate_interface_accept_offer_new_references_relationship_path(
          application_choice,
          @reference.id,
        )
      end
    end
  end
end
