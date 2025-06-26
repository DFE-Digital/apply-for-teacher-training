class ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponentPreview < ViewComponent::Preview
  def with_provider_name
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)
    pool_invite = FactoryBot.create(:pool_invite, :published, candidate:)
    provider = pool_invite.provider
    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    render ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent.new(
      application_form:,
      current_provider_user:,
      show_provider_name: true,
    )
  end

  def without_provider_name
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)
    pool_invite = FactoryBot.create(:pool_invite, :published, candidate:)
    provider = pool_invite.provider
    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    render ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent.new(
      application_form:,
      current_provider_user:,
      show_provider_name: false,
    )
  end
end
