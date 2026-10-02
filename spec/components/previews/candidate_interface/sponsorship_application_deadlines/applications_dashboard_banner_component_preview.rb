class CandidateInterface::SponsorshipApplicationDeadlines::ApplicationsDashboardBannerComponentPreview < ViewComponent::Preview
  include PreviewProviderHelper

  def with_one_approaching_deadline
    course_option = FactoryBot.create(
      :course_option,
      course: FactoryBot.create(:course, visa_sponsorship_application_deadline_at: 3.days.from_now, provider:),
    )
    FactoryBot.create(:application_choice, :unsubmitted, course_option:, application_form:)

    render(CandidateInterface::SponsorshipApplicationDeadlines::ApplicationsDashboardBannerComponent.new(application_form:))
  end

  def with_multiple_approaching_deadlines
    course_option_deadline_today = FactoryBot.create(
      :course_option,
      course: FactoryBot.create(:course, visa_sponsorship_application_deadline_at: 2.hours.from_now, provider:),
    )
    course_option_deadline_4_days_from_now = FactoryBot.create(
      :course_option,
      course: FactoryBot.create(:course, visa_sponsorship_application_deadline_at: 4.days.from_now, provider:),
    )

    FactoryBot.create(:application_choice, :unsubmitted, course_option: course_option_deadline_4_days_from_now, application_form:)
    FactoryBot.create(:application_choice, :unsubmitted, course_option: course_option_deadline_today, application_form:)

    render(CandidateInterface::SponsorshipApplicationDeadlines::ApplicationsDashboardBannerComponent.new(application_form:))
  end

  private

  def application_form
    @application_form ||= FactoryBot.create(:application_form, right_to_work_or_study: 'no')
  end

  def provider
    @provider ||= FactoryBot.create(:provider, code: unique_provider_code)
  end
end
