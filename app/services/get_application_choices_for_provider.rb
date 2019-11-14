class GetApplicationChoicesForProvider
  STATES_NOT_VISIBLE_TO_PROVIDER = %i[unsubmitted awaiting_references application_complete].freeze

  def self.call(provider:)
    ApplicationChoice.includes(:course)
    .where('courses.provider_id' => provider)
    .or(ApplicationChoice.includes(:course)
      .where('courses.accrediting_provider_id' => provider))
    .where('status NOT IN (?)', STATES_NOT_VISIBLE_TO_PROVIDER)
  end
end
