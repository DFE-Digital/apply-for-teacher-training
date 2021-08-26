class CandidateInterface::ReferencesGuidanceComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :references

  def initialize(references:)
    @references = references
  end

  def render?
    @references.blank? || references_section_incomplete?
  end

private

  def references_section_incomplete?
    !@references.first.application_form.references_completed
  end
end
