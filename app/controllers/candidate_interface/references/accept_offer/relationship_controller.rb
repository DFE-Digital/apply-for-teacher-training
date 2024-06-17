module CandidateInterface
  module References
    class AcceptOffer::RelationshipController < RelationshipController
      include AcceptOfferConfirmReferences

      def next_path
        candidate_interface_accept_offer_path(application_choice)
      end

      private

      def set_wizard
        @wizard = ReferenceWizard.new(
          current_step: :reference_relationship,
          reference_process: :accept_offer,
          application_choice:,
          reference: @reference,
          step_params: ActionController::Parameters.new(
            {
              reference_relationship: {
                relationship: params.dig(:relationship, :relationship)
              }
            }
          )
        )
      end
    end
  end
end
