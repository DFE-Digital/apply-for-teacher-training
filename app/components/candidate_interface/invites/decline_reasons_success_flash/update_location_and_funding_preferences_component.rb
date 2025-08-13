class CandidateInterface::Invites::DeclineReasonsSuccessFlash::UpdateLocationAndFundingPreferencesComponent < CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent
  def update_preferences_text
    render_change_funding_preferences? ? 'Update your location and funding preferences' : 'Update your location preferences'
  end

private

  def render_change_funding_preferences?
    return false unless application_form.published_preference_opt_in?

    application_form.published_preference.funding_type.present? || application_form.applied_only_to_salaried_courses?
  end
end
