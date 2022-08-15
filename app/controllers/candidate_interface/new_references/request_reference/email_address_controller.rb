module CandidateInterface
  module NewReferences
    class RequestReference::EmailAddressController < EmailAddressController
      include RequestReferenceOfferDashboard
      include RequestReferenceNewReferencesPath

      def previous_path
        candidate_interface_request_reference_new_references_name_path(
          @reference.referee_type.dasherize,
          @reference.id,
        )
      end
      helper_method :previous_path

      def next_path
        candidate_interface_request_reference_new_references_relationship_path(
          @reference.id,
        )
      end
    end
  end
end
