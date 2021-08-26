class CandidateInterface::ReferenceStatusesComponent < ViewComponent::Base
  include ViewHelper

  attr_reader :references

  def initialize(references:)
    @references = references
  end

  def render?
    @references.present?
  end
end
