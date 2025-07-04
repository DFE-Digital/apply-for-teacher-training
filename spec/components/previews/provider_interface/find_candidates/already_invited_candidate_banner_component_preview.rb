class ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponentPreview < ViewComponent::Preview
  def fac_status_banner_for_single_invite_not_applied_yet
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)
    pool_invite = FactoryBot.create(:pool_invite, :published, candidate:, application_form:)
    provider = pool_invite.provider
    provider2 = FactoryBot.create(:provider)
    current_provider_user = FactoryBot.create(:provider_user, providers: [provider, provider2])

    render ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent.new(
      application_form: application_form,
      current_provider_user: current_provider_user,
    )
  end

  def fac_status_banner_for_single_invite_not_applied_yet_without_provider_name
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)
    pool_invite = FactoryBot.create(:pool_invite, :published, candidate:, application_form:)
    provider = pool_invite.provider
    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    render ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent.new(
      application_form: application_form,
      current_provider_user: current_provider_user,
    )
  end

  def fac_status_banner_for_single_invite_where_candidate_has_applied
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)
    pool_invite = FactoryBot.create(:pool_invite, :published, candidate:, application_form:)
    provider = pool_invite.provider
    provider2 = FactoryBot.create(:provider)
    course = pool_invite.course

    FactoryBot.create(
      :application_choice,
      application_form: application_form,
      course_option: FactoryBot.create(:course_option, course: course),
      provider_ids: [provider.id],
    )

    current_provider_user = FactoryBot.create(:provider_user, providers: [provider, provider2])

    render ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent.new(
      application_form: application_form,
      current_provider_user: current_provider_user,
    )
  end
end
