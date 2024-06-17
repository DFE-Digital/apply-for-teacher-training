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

      private

      def set_wizard
        @wizard = ReferenceWizard.new(
          current_step: :reference_type,
          reference_process: :accept_offer,
          reference: @reference,
          return_to_path: return_to_path,
          application_choice:,
          step_params: ActionController::Parameters.new(
            {
              reference_type: {
                referee_type: params.dig(:type, :referee_type)
              }
            }
          )
        )
      end
    end
  end
end
