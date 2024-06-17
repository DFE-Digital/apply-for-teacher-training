module CandidateInterface
  module References
    class RequestReference::EmailAddressController < EmailAddressController
      #include RequestReferenceOfferDashboard

      #def next_path
      #  candidate_interface_request_reference_references_relationship_path(
      #    @reference.id,
      #  )
      #end

      #def set_email_address_form
      #  @reference_email_address_form = Reference::RequestRefereeEmailAddressForm.new(referee_email_address_param)
      #end

      #private

      #def set_wizard
      #  @wizard = ReferenceWizard.new(
      #    current_step: :reference_email_address,
      #    reference_process: :request_reference,
      #    current_application: current_candidate.current_application,
      #    reference: @reference,
      #    return_to_path: return_to_path,
      #    step_params: ActionController::Parameters.new(
      #      {
      #        reference_email_address: {
      #          email_address: params.dig(:email_address, :email_address)
      #        }
      #      }
      #    )
      #  )
      #end
    end
  end
end
