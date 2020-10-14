class TaskListItemReferencesComponent < ViewComponent::Base
  include ViewHelper

  def initialize(references:)
    @references = references
  end

  def colour_for(_reference)
    'grey'
  end

  def status_label_for(reference)
    I18n.t("candidate_reference_status.#{reference.feedback_status}")
  end

private

  attr_reader :references
end
