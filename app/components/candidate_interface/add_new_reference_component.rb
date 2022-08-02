module CandidateInterface
  class AddNewReferenceComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form)
      @application_form = application_form
    end

    def add_reference_link_title
      if at_least_one_reference?
        'Add another reference'
      else
        'Add reference'
      end
    end

    def options_for_add_reference_link
      if application_form.complete_references_information?
        { secondary: true }
      end
    end

    def at_least_one_reference?
      application_form.application_references.count.positive?
    end
  end
end
