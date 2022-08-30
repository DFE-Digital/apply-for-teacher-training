module CandidateInterface
  module NewReferences
    class RequestReference::NameController < NameController
      include RequestReferenceOfferDashboard

      def previous_path
        candidate_interface_request_reference_new_references_type_path(
          params[:referee_type],
          params[:id],
        )
      end
      helper_method :previous_path

      def next_path
        candidate_interface_request_reference_new_references_email_address_path(
          @reference&.id || current_application.application_references.last.id,
        )
      end
    end
  end
end
