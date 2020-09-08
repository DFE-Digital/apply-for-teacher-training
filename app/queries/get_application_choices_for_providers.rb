class GetApplicationChoicesForProviders
  DEFAULT_INCLUDES = [
    :accredited_provider,
    :offered_course_option,
    :provider,
    :site,
    application_form: %i[candidate application_references application_work_experiences application_volunteering_experiences application_qualifications],
    course: %i[provider],
    course_option: [{ course: %i[provider] }, :site],
  ].freeze

  def self.call(providers:, vendor_api: false, includes: DEFAULT_INCLUDES)
    providers = Array.wrap(providers).select(&:present?)

    raise MissingProvider if providers.none?

    statuses = vendor_api ? ApplicationStateChange.states_visible_to_provider_without_deferred : ApplicationStateChange.states_visible_to_provider

    ApplicationChoice.includes(*includes)
      .where('courses.provider_id' => providers, 'courses.recruitment_cycle_year' => RecruitmentCycle.years_visible_to_providers)
      .or(ApplicationChoice.includes(*includes)
        .where('courses.accredited_provider_id' => providers, 'courses.recruitment_cycle_year' => RecruitmentCycle.years_visible_to_providers))
      .where('status IN (?)', statuses)
  end
end
