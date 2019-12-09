class GetApplicationChoicesForProvider
  def self.call(provider:)
    raise MissingProvider unless provider.present?

    includes = [
      :course,
      :application_form,
      :provider,
      :site,
      application_form: %i[candidate references application_work_experiences application_volunteering_experiences application_qualifications],
    ]

    ApplicationChoice.includes(*includes)
      .where('courses.provider_id' => provider)
      .or(ApplicationChoice.includes(*includes)
        .where('courses.accrediting_provider_id' => provider))
      .where('status NOT IN (?)', ApplicationStateChange.states_not_visible_to_provider)
  end
end
