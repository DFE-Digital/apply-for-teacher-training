class CandidateInterface::TaskListItemReferencesComponent < ViewComponent::Base
  include ViewHelper

  def initialize(references:)
    @references = references
  end

  def colour_for(reference)
    I18n.t("candidate_reference_colours.#{reference.feedback_status}")
  end

  def status_label_for(reference)
    I18n.t("candidate_reference_status.#{reference.feedback_status}")
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
