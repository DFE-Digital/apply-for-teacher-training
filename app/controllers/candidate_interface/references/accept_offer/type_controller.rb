module CandidateInterface
  module References
    class AcceptOffer::TypeController < TypeController
      include AcceptOfferConfirmReferences

      def next_path
        candidate_interface_accept_offer_references_name_path(
          application_choice,
          @reference_type_form.referee_type,
          params[:id],
        )
      end
    end
  end
end
