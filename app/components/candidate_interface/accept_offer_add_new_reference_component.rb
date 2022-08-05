module CandidateInterface
  class AcceptOfferAddNewReferenceComponent < ViewComponent::Base
    include AddNewReferenceHelpers

    attr_reader :application_form, :application_choice

    def initialize(application_form:, application_choice:)
      @application_form = application_form
      @application_choice = application_choice
    end
  end
end
