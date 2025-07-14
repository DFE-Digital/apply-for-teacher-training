class ProviderInterface::CandidateInvitedBannerComponentPreview < ViewComponent::Preview
  def candidate_invited
    application_form = FactoryBot.build(:application_form, :completed, submitted_at: 1.day.ago)
    application_choice = FactoryBot.create(:application_choice, :awaiting_provider_decision, application_form:)
    pool_invite = FactoryBot.create(:pool_invite, :published, application_form:, course: application_choice.course)
    provider = pool_invite.provider
    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    render ProviderInterface::CandidateInvitedBannerComponent.new(
      application_choice:,
      current_provider_user:,
    )
  end
end
