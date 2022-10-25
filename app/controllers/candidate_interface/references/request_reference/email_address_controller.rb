module CandidateInterface
  module References
    class RequestReference::EmailAddressController < EmailAddressController
      include RequestReferenceOfferDashboard

      def next_path
        candidate_interface_request_reference_references_relationship_path(
          @reference.id,
        )
      end
    end
  end
end
