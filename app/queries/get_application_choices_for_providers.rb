class GetApplicationChoicesForProviders
  DEFAULT_INCLUDES = [
    :accredited_provider,
    :offered_course_option,
    :provider,
    :site,
    application_form: %i[candidate application_references application_work_experiences application_volunteering_experiences application_qualifications application_work_history_breaks],
    course: %i[provider accredited_provider],
    course_option: [{ course: %i[provider] }, :site],
  ].freeze

  DEFAULT_RECRUITMENT_CYCLE_YEAR = RecruitmentCycle.years_visible_to_providers

  def self.call(providers:, vendor_api: false, includes: DEFAULT_INCLUDES, recruitment_cycle_year: DEFAULT_RECRUITMENT_CYCLE_YEAR)
    providers = Array.wrap(providers).select(&:present?)

    raise MissingProvider if providers.none?

    statuses = vendor_api ? ApplicationStateChange.states_visible_to_provider_without_deferred : ApplicationStateChange.states_visible_to_provider

    with_courses = ApplicationChoice.annotate_with_courses

    applications = with_courses.where(
      'original_training_provider_id' => providers,
      'original_course_year' => recruitment_cycle_year,
    ).or(
      with_courses.where(
        'original_ratifying_provider_id' => providers,
        'original_course_year' => recruitment_cycle_year,
      ),
    ).or(
      with_courses.where(
        'current_training_provider_id' => providers,
        'current_course_year' => recruitment_cycle_year,
      ),
    ).or(
      with_courses.where(
        'current_ratifying_provider_id' => providers,
        'current_course_year' => recruitment_cycle_year,
      ),
    )
    .where('status IN (?)', statuses)

    applications.includes(*includes)
  end
end
