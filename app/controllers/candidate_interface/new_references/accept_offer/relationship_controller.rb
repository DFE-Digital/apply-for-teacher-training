module CandidateInterface
  module NewReferences
    class AcceptOffer::RelationshipController < RelationshipController
      include AcceptOfferConfirmReferences

      def references_relationship_path
        candidate_interface_accept_offer_new_references_relationship_path(
          application_choice,
          @reference.id,
        )
      end
      helper_method :references_relationship_path

      def edit_relationship_path
        candidate_interface_accept_offer_new_references_edit_relationship_path(
          application_choice,
          @reference.id,
          return_to: params[:return_to],
        )
      end
      helper_method :edit_relationship_path

      def next_path
        candidate_interface_accept_offer_path(application_choice)
      end
    end
  end
end
