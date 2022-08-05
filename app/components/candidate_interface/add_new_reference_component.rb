module CandidateInterface
  class AddNewReferenceComponent < ViewComponent::Base
    include AddNewReferenceHelpers

    attr_reader :application_form

    def initialize(application_form)
      @application_form = application_form
    end
  end
end
