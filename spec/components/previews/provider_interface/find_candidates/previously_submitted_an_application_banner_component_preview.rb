class ProviderInterface::FindCandidates::PreviouslySubmittedAnApplicationBannerComponentPreview < ViewComponent::Preview
  def previous_applications_in_two_cycles
    candidate = FactoryBot.create(:candidate)
    provider = FactoryBot.create(:provider)
    current_provider_user = FactoryBot.create(:provider_user, providers: [provider])

    course_current = FactoryBot.create(:course, provider:)
    course_option_current = FactoryBot.create(:course_option, course: course_current)
    application_form_current = FactoryBot.create(:application_form, :completed, candidate:, submitted_at: 1.day.ago)

    FactoryBot.create(:application_choice, :awaiting_provider_decision, application_form: application_form_current, course_option: course_option_current)

    previous_year = CycleTimetableHelper.previous_year
    mid_cycle_date = CycleTimetableHelper.mid_cycle(previous_year)
    course_previous = FactoryBot.create(:course, provider:, recruitment_cycle_year: previous_year)
    course_option_previous = FactoryBot.create(:course_option, course: course_previous)
    application_form_previous = FactoryBot.create(
      :application_form,
      :completed,
      recruitment_cycle_year: previous_year,
      submitted_at: mid_cycle_date,
      created_at: mid_cycle_date,
      updated_at: mid_cycle_date,
      candidate:,
    )
    FactoryBot.create(:application_choice, :withdrawn, application_form: application_form_previous, course_option: course_option_previous)

    render ProviderInterface::FindCandidates::PreviouslySubmittedAnApplicationBannerComponent.new(
      application_form: application_form_current,
      current_provider_user: current_provider_user,
    )
  end
end
