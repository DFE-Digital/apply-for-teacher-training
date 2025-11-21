module CandidateInterface
  class ReferencesComponent < ViewComponent::Base
    include ViewHelper

    attr_reader :references, :reference_condition

    delegate :met?, to: :reference_condition, allow_nil: true, prefix: true

    def initialize(references:, reference_condition:)
      @references = references
      @reference_condition = reference_condition
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
