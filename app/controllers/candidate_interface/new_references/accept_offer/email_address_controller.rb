module CandidateInterface
  module NewReferences
    class AcceptOffer::EmailAddressController < EmailAddressController
      include AcceptOfferConfirmReferences

      def references_email_address_path
        candidate_interface_accept_offer_new_references_email_address_path(
          application_choice,
          @reference.id,
        )
      end

      def edit_email_address_path
        candidate_interface_accept_offer_new_references_edit_email_address_path(
          application_choice,
          @reference.id,
          return_to: params[:return_to],
        )
      end
      helper_method :edit_email_address_path

      def previous_path
        candidate_interface_accept_offer_new_references_name_path(
          application_choice,
          @reference.referee_type.dasherize,
          @reference.id,
        )
      end
      helper_method :previous_path

      def next_path
        candidate_interface_accept_offer_new_references_relationship_path(
          application_choice,
          @reference.id,
        )
      end
    end
  end
end
