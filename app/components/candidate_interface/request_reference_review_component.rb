module CandidateInterface
  class RequestReferenceReviewComponent < ReferencesReviewComponent
    attr_reader :reference

    def initialize(reference, reference_process:)
      @reference = reference
      @reference_process = reference_process
    end

    def edit_type_path(reference)
      candidate_interface_request_reference_references_edit_type_path(
        reference.referee_type,
        reference.id,
        return_to_params,
      )
    end

    def edit_name_path(reference)
      candidate_interface_request_reference_references_edit_name_path(
        reference.id,
        return_to_params,
      )
    end

    def edit_email_address_path(reference)
      candidate_interface_request_reference_references_edit_email_address_path(
        reference.id,
        return_to_params,
      )
    end

    def edit_relationship_path(reference)
      candidate_interface_request_reference_references_edit_relationship_path(
        reference.id,
        return_to_params,
      )
    end

    def return_to_params
      { return_to: 'request-reference-review' }
    end
  end
end
