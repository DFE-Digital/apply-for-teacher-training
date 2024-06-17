module CandidateInterface
  class AcceptOfferAddNewReferenceComponent < ViewComponent::Base
    include AddNewReferenceHelpers
    include GovukVisuallyHiddenHelper

    attr_reader :application_form, :application_choice

    def initialize(application_form:, application_choice:, reference_process:)
      @application_form = application_form
      @application_choice = application_choice
      @reference_process = reference_process
    end

    def options_for_add_reference_link
      (super || {}).merge(id: 'accept-offer-add-new-reference-field')
    end
  end
end
