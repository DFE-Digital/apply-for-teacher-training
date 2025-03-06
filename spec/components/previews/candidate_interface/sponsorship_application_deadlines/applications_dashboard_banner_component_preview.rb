class CandidateInterface::SponsorshipApplicationDeadlines::ApplicationsDashboardBannerComponentPreview < ViewComponent::Preview
  def with_one_approaching_deadline
    application_form = FactoryBot.create(:application_form, right_to_work_or_study: 'no')
    course_option = FactoryBot.create(:course_option, course: FactoryBot.create(:course, visa_sponsorship_application_deadline_at: 3.days.from_now))
    FactoryBot.create(:application_choice, :unsubmitted, course_option:, application_form:)

    render(CandidateInterface::SponsorshipApplicationDeadlines::ApplicationsDashboardBannerComponent.new(application_form:))
  end

  def with_multiple_approaching_deadlines
    application_form = FactoryBot.create(:application_form, right_to_work_or_study: 'no')
    course_option_deadline_today = FactoryBot.create(:course_option, course: FactoryBot.create(:course, visa_sponsorship_application_deadline_at: 2.hours.from_now))
    course_option_deadline_4_days_from_now = FactoryBot.create(:course_option, course: FactoryBot.create(:course, visa_sponsorship_application_deadline_at: 4.days.from_now))

    FactoryBot.create(:application_choice, :unsubmitted, course_option: course_option_deadline_4_days_from_now, application_form:)
    FactoryBot.create(:application_choice, :unsubmitted, course_option: course_option_deadline_today, application_form:)

    render(CandidateInterface::SponsorshipApplicationDeadlines::ApplicationsDashboardBannerComponent.new(application_form:))
  end
end
