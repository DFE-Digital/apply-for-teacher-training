module CandidateInterface
  class AddReferenceComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form)
      @application_form = application_form
    end

    def enough_references_have_been_added?
      viable_references.count >= ApplicationForm::MINIMUM_COMPLETE_REFERENCES
    end

    def no_viable_references?
      viable_references.count.zero?
    end

  private

    def viable_references
      application_form.application_references.select do |reference|
        reference.not_requested_yet? ||
          reference.feedback_requested? ||
          reference.feedback_provided?
      end
    end
  end
end
