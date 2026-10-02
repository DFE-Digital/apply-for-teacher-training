class ProviderInterface::CandidateInvitedBannerComponentPreview < ViewComponent::Preview
  include PreviewProviderHelper

  def candidate_invited
    application_form = FactoryBot.build(:application_form, :completed, submitted_at: 1.day.ago)
    application_choice = FactoryBot.create(:application_choice, :awaiting_provider_decision, application_form:, course_option:)
    _pool_invite = FactoryBot.create(:pool_invite, :published, application_form:, course:, provider:)
    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    render ProviderInterface::CandidateInvitedBannerComponent.new(
      application_choice:,
      current_provider_user:,
    )
  end

  private

  def provider
    @provider ||= FactoryBot.create(:provider, code: unique_provider_code)
  end

  def course
    @course ||= FactoryBot.create(:course, provider:)
  end

  def course_option
    @course_option ||= FactoryBot.create(:course_option, course: course)
  end
end
