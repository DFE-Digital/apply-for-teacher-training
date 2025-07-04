class ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponentPreview < ViewComponent::Preview
  def fac_status_banner_for_multiple_invite_with_provider_name
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)

    provider = Provider.find_or_create_by!(code: 'PV001')
    provider2 = Provider.find_or_create_by!(code: 'PV991')
    course1 = Course.find_or_create_by!(code: 'COURSE1', provider:)
    course2 = Course.find_or_create_by!(code: 'COURSE2', provider:)

    FactoryBot.create(:pool_invite, :published, candidate:, application_form:, provider:, course: course1)
    FactoryBot.create(:pool_invite, :published, candidate:, application_form:, provider:, course: course2)

    current_provider_user = FactoryBot.create(:provider_user, providers: [provider, provider2])

    render ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent.new(
      application_form:,
      current_provider_user:,
    )
  end

  def fac_status_banner_for_multiple_invite_without_provider_name
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)

    provider = Provider.find_or_create_by!(code: 'PV000')

    course3 = Course.find_by(code: 'COURSE3', provider:) || FactoryBot.create(:course, code: 'COURSE3', provider:)
    course4 = Course.find_by(code: 'COURSE4', provider:) || FactoryBot.create(:course, code: 'COURSE4', provider:)

    FactoryBot.create(:pool_invite, :published, candidate:, application_form:, provider:, course: course3)
    FactoryBot.create(:pool_invite, :published, candidate:, application_form:, provider:, course: course4)

    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    render ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent.new(
      application_form:,
      current_provider_user:,
    )
  end

  def fac_status_banner_for_multiple_invite_where_candidate_has_applied
    candidate = FactoryBot.create(:candidate)
    application_form = FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)

    provider = Provider.find_or_create_by!(code: 'PV999')

    course5 = Course.find_by(code: 'COURSE5', provider:) || FactoryBot.create(:course, code: 'COURSE5', provider:)
    course6 = Course.find_by(code: 'COURSE6', provider:) || FactoryBot.create(:course, code: 'COURSE6', provider:)

    FactoryBot.create(:pool_invite, :published, candidate:, application_form:, provider:, course: course5)
    FactoryBot.create(:pool_invite, :published, candidate:, application_form:, provider:, course: course6)

    FactoryBot.create(
      :application_choice,
      application_form: application_form,
      course_option: FactoryBot.create(:course_option, course: course5),
      provider_ids: [provider.id],
    )

    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    render ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent.new(
      application_form:,
      current_provider_user:,
    )
  end
end
