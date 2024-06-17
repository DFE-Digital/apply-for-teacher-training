module CandidateInterface
  module References
    class AcceptOffer::EmailAddressController < EmailAddressController
      include AcceptOfferConfirmReferences

      def next_path
        candidate_interface_accept_offer_references_relationship_path(
          application_choice,
          @reference.id,
        )
      end

      private

      def set_wizard
        @wizard = ReferenceWizard.new(
          current_step: :reference_email_address,
          reference_process: :accept_offer,
          application_choice:,
          current_application: current_candidate.current_application,
          reference: @reference,
          return_to_path: return_to_path,
          step_params: ActionController::Parameters.new(
            {
              reference_email_address: {
                email_address: params.dig(:email_address, :email_address)
              }
            }
          )
        )
      end
    end
  end
end
