class ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponentPreview < ViewComponent::Preview
  include PreviewProviderHelper

  def fac_status_banner_for_single_invite_not_applied_yet
    pool_invite
    current_provider_user = FactoryBot.create(:provider_user, providers: [provider, provider_2])

    render ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent.new(
      application_form: application_form,
      current_provider_user: current_provider_user,
    )
  end

  def fac_status_banner_for_single_invite_not_applied_yet_without_provider_name
    pool_invite
    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    render ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent.new(
      application_form: application_form,
      current_provider_user: current_provider_user,
    )
  end

  def fac_status_banner_for_single_invite_where_candidate_has_applied
    pool_invite

    FactoryBot.create(
      :application_choice,
      application_form: application_form,
      course_option: FactoryBot.create(:course_option, course: course),
      provider_ids: [provider.id],
    )

    current_provider_user = FactoryBot.create(:provider_user, providers: [provider, provider_2])

    render ProviderInterface::FindCandidates::AlreadyInvitedCandidateBannerComponent.new(
      application_form: application_form,
      current_provider_user: current_provider_user,
    )
  end

  private

  def course
    @course ||= FactoryBot.create(:course, provider:)
  end

  def pool_invite
    @pool_invite ||= FactoryBot.create(:pool_invite, :published, candidate:, application_form:, provider:, course:)
  end

  def application_form
    @application_form ||= FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)
  end

  def candidate
    @candidate ||= FactoryBot.create(:candidate)
  end

  def provider
    @provider ||= FactoryBot.build(:provider, code: unique_provider_code)
  end

  def provider_2
    @provider_2 ||= FactoryBot.build(:provider, code: unique_provider_code)
  end
end
