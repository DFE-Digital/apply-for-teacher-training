class CandidateInterface::ShareDetailsComponent < ViewComponent::Base
  attr_reader :current_candidate

  def initialize(current_candidate)
    @current_candidate = current_candidate
  end

private

  def path_to_continue
    if current_candidate.published_preferences.any?
      candidate_interface_draft_preference_publish_preferences_path(
        current_candidate.published_preferences.last,
      )
    else
      new_candidate_interface_pool_opt_in_path
    end
  end
end
