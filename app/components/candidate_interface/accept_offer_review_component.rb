module CandidateInterface
  class AcceptOfferReviewComponent < ReferencesReviewComponent
    #### Do we need this component?
    attr_reader :application_form, :application_choice

    def initialize(application_form:, application_choice:, reference_process:)
      @application_form = application_form
      @application_choice = application_choice
      @references = application_form.application_references.creation_order
      @referewnce_process = reference_process

      super(
        application_form: @application_form,
        application_choice: @application_choice,
        references: @references,
        reference_process:
      )
    end

    def show_missing_banner?
      false
    end

    def return_to_params
      { 'return_to' => 'accept-offer' } ## can we make this dynamic?
    end

    def confirm_destroy_path(reference)
      # better, more generic name?
      candidate_interface_confirm_destroy_new_reference_path(
        @reference_process,
        reference,
        params: {
          application_id: @application_choice
        }
      )
    end
  end
end
