class CandidateInterface::SponsorshipApplicationDeadlines::ApplicationChoiceBannerComponentPreview < ViewComponent::Preview
  include PreviewProviderHelper

  def less_than_one_day_until_deadline
    course_option = FactoryBot.create(
      :course_option,
      course: FactoryBot.create(:course, visa_sponsorship_application_deadline_at: 2.hours.from_now, provider:),
    )
    application_choice = FactoryBot.create(:application_choice, :unsubmitted, course_option:, application_form:)

    render(CandidateInterface::SponsorshipApplicationDeadlines::ApplicationChoiceBannerComponent.new(application_choice:))
  end

  def ten_days_until_deadline
    course_option = FactoryBot.create(
      :course_option,
      course: FactoryBot.create(:course, visa_sponsorship_application_deadline_at: 10.days.from_now + 2.seconds, provider:),
    )
    application_choice = FactoryBot.create(:application_choice, :unsubmitted, course_option:, application_form:)

    render(CandidateInterface::SponsorshipApplicationDeadlines::ApplicationChoiceBannerComponent.new(application_choice:))
  end

  private

  def application_form
    @application_form ||= FactoryBot.create(:application_form, right_to_work_or_study: 'no')
  end

  def provider
    @provider ||= FactoryBot.create(:provider, code: unique_provider_code)
  end
end
