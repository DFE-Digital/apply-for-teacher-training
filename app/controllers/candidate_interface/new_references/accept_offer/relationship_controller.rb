module CandidateInterface
  module NewReferences
    class AcceptOffer::RelationshipController < RelationshipController
      include AcceptOfferConfirmReferences

      def previous_path
        candidate_interface_accept_offer_new_references_email_address_path(
          application_choice,
          @reference.id,
        )
      end
      helper_method :previous_path

      def next_path
        candidate_interface_accept_offer_path(application_choice)
      end
    end
  end
end
