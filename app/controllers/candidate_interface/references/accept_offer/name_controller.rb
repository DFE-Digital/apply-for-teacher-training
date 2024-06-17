module CandidateInterface
  module References
    class AcceptOffer::NameController < NameController
      include AcceptOfferConfirmReferences

      def next_path
        candidate_interface_accept_offer_references_email_address_path(
          application_choice,
          @reference&.id || current_application.application_references.creation_order.last.id,
        )
      end

      private

      def set_wizard
        @wizard = ReferenceWizard.new(
          current_step: :reference_name,
          reference_process: :accept_offer,
          application_choice:,
          current_application:,
          reference: @reference,
          return_to_path:,
          step_params: ActionController::Parameters.new(
            {
              reference_name: {
                name: params.dig(:name, :name),
                referee_type: params[:referee_type],
              }
            }
          )
        )
      end
    end
  end
end
