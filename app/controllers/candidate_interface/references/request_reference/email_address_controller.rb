module CandidateInterface
  module References
    class RequestReference::EmailAddressController < EmailAddressController
      include RequestReferenceOfferDashboard

      def next_path
        if @reference_email_address_form.show_interruption?(@reference)
          return_to_params = return_to_request_reference_review? ? { return_to: 'request-reference-review' } : nil
          candidate_interface_request_reference_references_interruption_path(
            @reference.id, params: return_to_params
          )
        else
          return_to_path ||
            candidate_interface_request_reference_references_relationship_path(@reference.id)
        end
      end
    end
  end
end
