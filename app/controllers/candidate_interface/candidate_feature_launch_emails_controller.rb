class CandidateInterface::CandidateFeatureLaunchEmailsController < CandidateInterface::CandidateInterfaceController
  def show
    redirect_to change_preferences_path
  end

private

  def change_preferences_path
    if current_candidate.published_preferences.last&.opt_out?
      edit_candidate_interface_pool_opt_in_path(current_candidate.published_preferences.last)
    elsif current_candidate.published_preferences.blank?
      new_candidate_interface_pool_opt_in_path
    else
      candidate_interface_draft_preference_publish_preferences_path(current_candidate.published_preferences.last)
    end
  end
end
