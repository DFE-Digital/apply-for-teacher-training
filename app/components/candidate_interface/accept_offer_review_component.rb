module CandidateInterface
  class AcceptOfferReviewComponent < ReferencesReviewComponent
    attr_reader :application_form, :application_choice

    def initialize(application_form:, application_choice:)
      @application_form = application_form
      @application_choice = application_choice
      @references = application_form.application_references.creation_order

      super(application_form: @application_form, application_choice: @application_choice, references: @references)
    end

    def show_missing_banner?(_reference)
      false
    end

    def return_to_params
      { 'return_to' => 'accept-offer' }
    end

    def confirm_destroy_path(reference)
      candidate_interface_accept_offer_confirm_destroy_new_reference_path(
        application_choice.id,
        reference,
      )
    end
  end
end
