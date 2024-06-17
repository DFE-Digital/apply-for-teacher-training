module CandidateInterface
  module References
    class RequestReference::TypeController < TypeController
      #include RequestReferenceOfferDashboard

      #def next_path
      #  candidate_interface_request_reference_references_name_path(
      #    @reference_type_form.referee_type,
      #    params[:id],
      #  )
      #end

      #private

      #def set_wizard
      #  @wizard = ReferenceWizard.new(
      #    current_step: :reference_type,
      #    reference_process: :request_reference,
      #    reference: @reference,
      #    return_to_path: return_to_path,
      #    step_params: ActionController::Parameters.new(
      #      {
      #        reference_type: {
      #          referee_type: params.dig(:type, :referee_type)
      #        }
      #      }
      #    )
      #  )
      #end
    end
  end
end
