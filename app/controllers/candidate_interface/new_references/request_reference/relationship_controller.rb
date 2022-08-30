module CandidateInterface
  module NewReferences
    class RequestReference::RelationshipController < RelationshipController
      include RequestReferenceOfferDashboard

      def previous_path
        candidate_interface_request_reference_new_references_email_address_path(
          @reference.id,
        )
      end
      helper_method :previous_path

      def next_path
        candidate_interface_new_references_request_reference_review_path(@reference.id)
      end
    end
  end
end
