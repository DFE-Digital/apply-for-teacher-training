 module CandidateInterface
  module NewReferences
    class AcceptOffer::TypeController < TypeController
      include AcceptOfferConfirmReferences

      def references_type_path
        candidate_interface_accept_offer_new_references_type_path(
          application_choice,
          params[:referee_type],
          params[:id]
        )
      end
      helper_method :references_type_path

      def reference_new_type_path
        candidate_interface_accept_offer_new_references_type_path(
          application_choice,
          params[:referee_type],
          params[:id]
        )
      end
      helper_method :reference_new_type_path

      def reference_edit_type_path
        candidate_interface_accept_offer_new_references_edit_type_path(
          application_choice,
          @reference.id,
          return_to: params[:return_to]
        )
      end
      helper_method :reference_edit_name_path

      def next_path
        candidate_interface_accept_offer_new_references_name_path(
          application_choice,
          @reference_type_form.referee_type,
          params[:id]
        )
      end
    end
  end
end
