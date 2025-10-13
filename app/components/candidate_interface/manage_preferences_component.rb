class CandidateInterface::ManagePreferencesComponent < ViewComponent::Base
  attr_reader :application_form

  def initialize(application_form:)
    @application_form = application_form
  end

  def render?
    application_form.submitted_applications?
  end

  def pool_opt_in?
    application_form.published_preferences&.last&.opt_in?
  end

private

  def path_to_change_preferences
    if application_form.published_preferences.last&.opt_out?
      edit_candidate_interface_pool_opt_in_path(application_form.published_preferences.last)
    elsif application_form.published_preferences.blank?
      new_candidate_interface_pool_opt_in_path
    else
      candidate_interface_draft_preference_publish_preferences_path(application_form.published_preferences.last)
    end
  end
end
