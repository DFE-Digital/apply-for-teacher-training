class ProviderInterface::FindCandidates::LocationPreferencesComponentPreview < ViewComponent::Preview
  def specific_locations
    application_form = FactoryBot.create(:application_form)
    candidate_preference = FactoryBot.create(:candidate_preference, :specific_locations, candidate: application_form.candidate)
    FactoryBot.create(:candidate_location_preference, :manchester, candidate_preference:)
    FactoryBot.create(:candidate_location_preference, :liverpool, candidate_preference:)

    render ProviderInterface::FindCandidates::LocationPreferencesComponent.new(application_form:)
  end

  def train_anywhere
    application_form = FactoryBot.create(:application_form)
    FactoryBot.create(:candidate_preference, :anywhere_in_england, candidate: application_form.candidate)

    render ProviderInterface::FindCandidates::LocationPreferencesComponent.new(application_form:)
  end
end
