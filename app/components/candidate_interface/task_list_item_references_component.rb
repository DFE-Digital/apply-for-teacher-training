class CandidateInterface::TaskListItemReferencesComponent < ViewComponent::Base
  include ViewHelper

  def initialize(references:)
    @references = references
  end

private

  attr_reader :references

  def references_path
    if @references.present?
      Rails.application.routes.url_helpers.candidate_interface_references_review_path
    else
      Rails.application.routes.url_helpers.candidate_interface_references_start_path
    end
  end
end
