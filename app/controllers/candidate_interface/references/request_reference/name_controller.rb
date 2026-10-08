module CandidateInterface
  module References
    class RequestReference::NameController < NameController
      include RequestReferenceOfferDashboard

      def next_path
        candidate_interface_request_reference_references_email_address_path(
          @reference&.id || @application_form.application_references.creation_order.last.id,
        )
      end
    end
  end
end
