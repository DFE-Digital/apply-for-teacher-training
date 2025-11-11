class ProviderInterface::FindCandidates::CandidateSearchComponentPreview < ViewComponent::Preview
  def default
    render ProviderInterface::FindCandidates::CandidateSearchComponent.new(
      filter:,
    )
  end

private

  def filter
    ProviderInterface::ProviderApplicationsFilter.new(
      params: ActionController::Parameters.new({}),
      provider_user: ProviderUser.new,
      state_store: StateStores::RedisStore.new(key: 'candidate_seach_component_preview'),
    )
  end
end
