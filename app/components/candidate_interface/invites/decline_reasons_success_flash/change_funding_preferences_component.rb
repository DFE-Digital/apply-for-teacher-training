class CandidateInterface::Invites::DeclineReasonsSuccessFlash::ChangeFundingPreferencesComponent < CandidateInterface::Invites::DeclineReasonsSuccessFlashComponent
  def render_change_preferences?
    return false unless application_form.published_preference_opt_in?

    application_form.published_preference.funding_type.present? || application_form.applied_only_to_salaried_courses?
  end
end
