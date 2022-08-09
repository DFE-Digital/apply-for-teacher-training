module CandidateInterface
  class NewReferencesAcceptOfferReviewComponent < NewReferencesReviewComponent
    attr_reader :application_form, :application_choice

    def initialize(application_form:, application_choice:)
      @application_form = application_form
      @application_choice = application_choice
      @references = application_form.application_references

      super(application_form: @application_form, references: @references)
    end

    def show_missing_banner?
      false
    end

    def edit_name_path(reference)
      candidate_interface_accept_offer_new_references_edit_name_path(
        application_choice.id,
        reference.id,
        return_to_params,
      )
    end

    def edit_type_path(reference)
      candidate_interface_accept_offer_new_references_edit_type_path(
        application_choice.id,
        reference.referee_type,
        reference.id,
        return_to_params,
      )
    end

    def edit_email_address_path(reference)
      candidate_interface_accept_offer_new_references_edit_email_address_path(
        application_choice.id,
        reference.id,
        return_to_params,
      )
    end

    def edit_relationship_path(reference)
      candidate_interface_accept_offer_new_references_edit_relationship_path(
        application_choice.id,
        reference.id,
        return_to_params,
      )
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
