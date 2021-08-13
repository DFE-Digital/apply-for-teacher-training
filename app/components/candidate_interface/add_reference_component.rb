module CandidateInterface
  class AddReferenceComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form

    def initialize(application_form)
      @application_form = application_form
    end

    def no_viable_references?
      viable_references.count.zero?
    end

    def one_viable_reference?
      viable_references.one?
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
