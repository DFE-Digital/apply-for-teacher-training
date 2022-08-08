class CandidateInterface::NewReferenceStatusesComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :reference

  def initialize(reference:)
    @reference = reference
  end

  def feedback_status_label(reference)
    govuk_tag(
      text: t("candidate_new_reference_status.#{reference.feedback_status}"),
      colour: t("candidate_new_reference_colours.#{reference.feedback_status}"),
    )
  end
end
