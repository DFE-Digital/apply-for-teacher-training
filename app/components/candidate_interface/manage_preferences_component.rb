class CandidateInterface::ManagePreferencesComponent < ViewComponent::Base
  attr_reader :current_candidate, :application_form

  def initialize(current_candidate:, application_form:)
    @current_candidate = current_candidate
    @application_form = application_form
  end

  def render?
    FeatureFlag.active?(:candidate_preferences) && application_form.submitted_applications?
  end

  def pool_opt_in?
    current_candidate.published_preferences&.last&.opt_in?
  end

private

  def path_to_change_preferences
    if current_candidate.published_preferences.any?
      candidate_interface_draft_preference_publish_preferences_path(current_candidate.published_preferences.last)
    else
      new_candidate_interface_pool_opt_in_path
    end
  end
end
