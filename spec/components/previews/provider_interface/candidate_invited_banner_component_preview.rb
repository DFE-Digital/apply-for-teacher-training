class ProviderInterface::CandidateInvitedBannerComponentPreview < ViewComponent::Preview
  def candidate_invited_but_not_applied_yet_view
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)
    pool_invite = FactoryBot.create(:pool_invite, :published, candidate:)
    provider = pool_invite.provider
    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    render ProviderInterface::CandidateInvitedBannerComponent.new(
      application_form:,
      current_provider_user:,
    )
  end
end
