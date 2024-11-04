module CandidateInterface
  module References
    class RequestReference::ReferencesInterruptionsController < InterruptionsController
      include RequestReferenceOfferDashboard

      def set_navigation_links
        @next_step = return_to_path || candidate_interface_request_reference_references_relationship_path(@reference.id)

        return_to_params = return_to_request_reference_review? ? { return_to: 'request-reference-review' } : nil
        @back_link = candidate_interface_request_reference_references_edit_email_address_path(@reference.id, params: return_to_params)
      end
    end
  end
end
