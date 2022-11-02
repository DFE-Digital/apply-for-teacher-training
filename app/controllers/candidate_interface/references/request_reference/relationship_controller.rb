module CandidateInterface
  module References
    class RequestReference::RelationshipController < RelationshipController
      include RequestReferenceOfferDashboard

      def next_path
        candidate_interface_references_request_reference_review_path(@reference.id)
      end
    end
  end
end
