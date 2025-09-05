module CandidateInterface
  class ReferencesComponent < ApplicationComponent
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

    def rows
      references.map do |reference|
        {
          key: govuk_link_to(reference.name, candidate_interface_application_offer_dashboard_reference_path(reference.id)),
          value: tag.strong('Received by training provider'),
        }
      end
    end
  end
end
