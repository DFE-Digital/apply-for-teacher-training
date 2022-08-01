module CandidateInterface
  class AddNewReferenceComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form)
      @application_form = application_form
    end

    def options_for_add_reference_link
      if application_form.complete_references_information?
        { secondary: true }
      end
    end
  end
end
