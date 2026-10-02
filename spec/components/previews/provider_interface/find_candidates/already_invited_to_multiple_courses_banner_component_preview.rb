class ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponentPreview < ViewComponent::Preview
  include PreviewProviderHelper

  def fac_status_banner_for_multiple_invite_with_provider_name
    pool_1
    pool_2

    current_provider_user = FactoryBot.create(:provider_user, providers: [provider, provider_2])

    render ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent.new(
      application_form:,
      current_provider_user:,
    )
  end

  def fac_status_banner_for_multiple_invite_without_provider_name
    pool_1
    pool_2

    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    render ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent.new(
      application_form:,
      current_provider_user:,
    )
  end

  def fac_status_banner_for_multiple_invite_where_candidate_has_applied
    pool_1
    pool_2

    FactoryBot.create(
      :application_choice,
      application_form: application_form,
      course_option: FactoryBot.create(:course_option, course: course_1),
      provider_ids: [provider.id],
    )

    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    render ProviderInterface::FindCandidates::AlreadyInvitedToMultipleCoursesBannerComponent.new(
      application_form:,
      current_provider_user:,
    )
  end

private

  def candidate
    @candidate ||= FactoryBot.create(:candidate)
  end

  def application_form
    @application_form ||= FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)
  end

  def provider
    @provider ||= FactoryBot.build(:provider, code: unique_provider_code)
  end

  def provider_2
    @provider_2 ||= FactoryBot.build(:provider, code: unique_provider_code)
  end

  def course_1
    @course_1 ||= FactoryBot.create(:course, provider: provider)
  end

  def course_2
    @course_2 ||= FactoryBot.create(:course, provider: provider)
  end

  def pool_1
    @pool_1 ||= FactoryBot.create(:pool_invite, :published, candidate:, application_form:, provider:, course: course_1)
  end

  def pool_2
    @pool_2 ||= FactoryBot.create(:pool_invite, :published, candidate:, application_form:, provider:, course: course_2)
  end
end
