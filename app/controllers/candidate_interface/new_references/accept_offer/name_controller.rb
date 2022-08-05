module CandidateInterface
  module NewReferences
    class AcceptOffer::NameController < NameController
      include AcceptOfferConfirmReferences

      def references_name_path
        candidate_interface_accept_offer_new_references_name_path(
          application_choice,
          params[:referee_type],
          params[:id]
        )
      end
      helper_method :references_name_path

      def reference_edit_name_path
        candidate_interface_accept_offer_new_references_edit_name_path(
          application_choice,
          @reference.id,
          return_to: params[:return_to]
        )
      end
      helper_method :reference_edit_name_path

      def next_path
        candidate_interface_accept_offer_new_references_email_address_path(
          application_choice,
          @reference&.id || current_application.application_references.last.id
        )
      end
    end
  end
end
