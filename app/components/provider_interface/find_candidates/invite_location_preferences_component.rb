class ProviderInterface::FindCandidates::InviteLocationPreferencesComponent < ProviderInterface::FindCandidates::LocationPreferencesComponent
  def preferences_text
    t('.specific_locations')
  end
end
