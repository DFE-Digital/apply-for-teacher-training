module CandidateInterface
  class AddNewReferenceComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form)
      @application_form = application_form
    end

    def add_reference_link_title
      t('application_form.new_references.add_reference', count: application_form.application_references.count)
    end

    def options_for_add_reference_link
      if application_form.complete_references_information?
        { secondary: true }
      end
    end
  end
end
