class ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponentPreview < ViewComponent::Preview
  def with_provider_name
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)

    provider = Provider.find_or_create_by!(code: 'PV001')
    course1 = Course.find_or_create_by!(code: 'COURSE1', provider:)
    course2 = Course.find_or_create_by!(code: 'COURSE2', provider:)

    FactoryBot.create(:pool_invite, :published, candidate:, provider:, course: course1)
    FactoryBot.create(:pool_invite, :published, candidate:, provider:, course: course2)

    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    render ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent.new(
      application_form:,
      current_provider_user:,
      show_provider_name: true,
    )
  end

  def without_provider_name
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)

    provider = Provider.find_or_create_by!(code: 'PV000')

    course3 = Course.find_by(code: 'COURSE3', provider:) || FactoryBot.create(:course, code: 'COURSE3', provider:)
    course4 = Course.find_by(code: 'COURSE4', provider:) || FactoryBot.create(:course, code: 'COURSE4', provider:)

    FactoryBot.create(:pool_invite, :published, candidate:, provider:, course: course3)
    FactoryBot.create(:pool_invite, :published, candidate:, provider:, course: course4)

    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    render ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent.new(
      application_form:,
      current_provider_user:,
      show_provider_name: false,
    )
  end
end
