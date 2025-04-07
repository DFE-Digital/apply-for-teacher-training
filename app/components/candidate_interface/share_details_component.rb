class CandidateInterface::ShareDetailsComponent < ViewComponent::Base
  attr_reader :current_candidate

  def initialize(current_candidate)
    @current_candidate = current_candidate
  end

private

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
