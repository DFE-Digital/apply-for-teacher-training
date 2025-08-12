# frozen_string_literal: true

class CandidateInterface::Invites::DeclineReasonsSuccessFlash::UpdateLocationAndFundingPreferencesComponent < CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent
  def update_preferences_text
    render_change_funding_preferences? ? 'Update your location and funding preferences' : 'Update your location preferences'
  end

private

  def render_change_funding_preferences?
    return false unless candidate.published_preference_opt_in?

    candidate.published_preference.funding_type.present? || candidate.applied_only_to_salaried_courses?
  end
end
