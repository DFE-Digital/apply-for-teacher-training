class CandidateInterface::CandidateFeatureLaunchEmailsController < CandidateInterface::CandidateInterfaceController
  def show
    redirect_to change_preferences_path
  end

private

  def change_preferences_path
    if current_application.published_preference&.opt_out?
      edit_candidate_interface_pool_opt_in_path(current_application.published_preference)
    elsif current_application.published_preference.blank?
      new_candidate_interface_pool_opt_in_path
    else
      candidate_interface_draft_preference_publish_preferences_path(current_application.published_preference)
    end
  end
end
