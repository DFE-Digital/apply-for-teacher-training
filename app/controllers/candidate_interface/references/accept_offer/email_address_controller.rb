module CandidateInterface
  module References
    class AcceptOffer::EmailAddressController < EmailAddressController
      include AcceptOfferConfirmReferences

      def next_path
        if @reference_email_address_form.personal_email_address?(@reference)
          return_to_params = return_to_offer? ? { return_to: 'accept-offer' } : nil
          candidate_interface_accept_offer_references_interruption_path(
            application_choice,
            @reference.id, params: return_to_params
          )
        else
          return_to_path || candidate_interface_accept_offer_references_relationship_path(
            application_choice,
            @reference.id,
          )
        end
      end
    end
  end
end
