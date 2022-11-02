module CandidateInterface
  module References
    class AcceptOffer::RelationshipController < RelationshipController
      include AcceptOfferConfirmReferences

      def next_path
        candidate_interface_accept_offer_path(application_choice)
      end
    end
  end
end
