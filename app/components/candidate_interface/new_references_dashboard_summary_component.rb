module CandidateInterface
  class NewReferencesDashboardSummaryComponent < ViewComponent::Base
    include ViewHelper
    attr_reader :reference, :editable

    def initialize(reference:)
      @reference = ApplicationReference.find(reference)
    end

    def feedback_status_label(reference)
      govuk_tag(
        text: t("candidate_reference_status.#{reference.feedback_status}"),
        colour: t("candidate_reference_colours.#{reference.feedback_status}"),
      )
    end

    def history(reference)
      render(CandidateInterface::ReferenceHistoryComponent.new(reference))
    end
  end
end
