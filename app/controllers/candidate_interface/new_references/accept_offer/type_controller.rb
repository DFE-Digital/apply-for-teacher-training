module CandidateInterface
  module NewReferences
    class AcceptOffer::TypeController < TypeController
      include AcceptOfferConfirmReferences
      include AcceptOfferNewReferencesPath

      def previous_path
        candidate_interface_accept_offer_path(application_choice)
      end
      helper_method :previous_path

      def next_path
        candidate_interface_accept_offer_new_references_name_path(
          application_choice,
          @reference_type_form.referee_type,
          params[:id],
        )
      end
    end
  end
end
