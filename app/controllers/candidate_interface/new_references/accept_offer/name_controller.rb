module CandidateInterface
  module NewReferences
    class AcceptOffer::NameController < NameController
      include AcceptOfferConfirmReferences
      include AcceptOfferNewReferencesPath

      def previous_path
        candidate_interface_accept_offer_new_references_type_path(
          application_choice,
          params[:referee_type],
          params[:id],
        )
      end
      helper_method :previous_path

      def next_path
        candidate_interface_accept_offer_new_references_email_address_path(
          application_choice,
          @reference&.id || current_application.application_references.last.id,
        )
      end
    end
  end
end
