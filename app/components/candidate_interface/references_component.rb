module CandidateInterface
  class ReferencesComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :application_form, :reference_condition

    delegate :met?, to: :reference_condition, allow_nil: true, prefix: true

    def initialize(application_form:, reference_condition:)
      @application_form = application_form
      @reference_condition = reference_condition
    end

    def references
      application_form.application_references.creation_order
    end
  end
end
