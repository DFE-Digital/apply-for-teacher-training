class GetApplicationChoicesForProvider
  def self.call(provider:)
    raise MissingProvider unless provider.present?

    includes = [
      :course,
      :course_option,
      :application_form,
      :provider,
      :site,
      application_form: %i[candidate references application_work_experiences application_volunteering_experiences application_qualifications],
      course: %i[provider],
      course_option: [{ course: %i[provider] }, :site],
    ]

    ApplicationChoice.includes(*includes)
      .where('courses.provider_id' => provider)
      .or(ApplicationChoice.includes(*includes)
        .where('courses.accrediting_provider_id' => provider))
      .where('status IN (?)', ApplicationStateChange.states_visible_to_provider)
  end
end
