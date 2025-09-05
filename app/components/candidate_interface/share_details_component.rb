class CandidateInterface::ShareDetailsComponent < ApplicationComponent
  attr_reader :current_candidate, :submit_application

  def initialize(current_candidate, submit_application: false)
    @current_candidate = current_candidate
    @submit_application = submit_application
  end

  def render?
    FeatureFlag.active?(:candidate_preferences)
  end

private

  def app_card_class
    submit_application ? 'app-card app-grid-column--grey' : ''
  end

  def path_to_continue
    if current_candidate.published_preferences.last&.opt_out?
      edit_candidate_interface_pool_opt_in_path(current_candidate.published_preferences.last)
    elsif current_candidate.published_preferences.blank?
      new_candidate_interface_pool_opt_in_path
    else
      candidate_interface_draft_preference_publish_preferences_path(current_candidate.published_preferences.last)
    end
  end
end
