class GetApplicationChoicesForProvider
  STATES_NOT_VISIBLE_TO_PROVIDER = %i[unsubmitted awaiting_references application_complete].freeze

  def self.call(provider:)
    raise MissingProvider unless provider.present?

    includes = [
      :course,
      :application_form,
      :provider,
      :site,
      application_form: %i[candidate references application_work_experiences application_volunteering_experiences],
    ]

    ApplicationChoice.includes(*includes)
      .where('courses.provider_id' => provider)
      .or(ApplicationChoice.includes(*includes)
        .where('courses.accrediting_provider_id' => provider))
      .where('status NOT IN (?)', STATES_NOT_VISIBLE_TO_PROVIDER)
  end
end
