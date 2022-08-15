module CandidateInterface
  module NewReferences
    class RequestReference::TypeController < TypeController
      include RequestReferenceOfferDashboard
      include RequestReferenceNewReferencesPath

      def previous_path
        candidate_interface_request_reference_new_references_start_path
      end
      helper_method :previous_path

      def next_path
        candidate_interface_request_reference_new_references_name_path(
          @reference_type_form.referee_type,
          params[:id],
        )
      end
    end
  end
end
