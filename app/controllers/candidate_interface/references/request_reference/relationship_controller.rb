module CandidateInterface
  module References
    class RequestReference::RelationshipController < RelationshipController
      #include RequestReferenceOfferDashboard


      #def next_path
      #  candidate_interface_references_request_reference_review_path(@reference.id)
      #end

      #private

      #def set_wizard
      #  @wizard = ReferenceWizard.new(
      #    current_step: :reference_relationship,
      #    reference_process: :request_reference,
      #    reference: @reference,
      #    step_params: ActionController::Parameters.new(
      #      {
      #        reference_relationship: {
      #          relationship: params.dig(:relationship, :relationship)
      #        }
      #      }
      #    )
      #  )
      #end
    end
  end
end
