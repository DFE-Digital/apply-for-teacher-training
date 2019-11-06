class GetApplicationChoicesForProvider
  STATES_NOT_VISIBLE_TO_PROVIDER = %i[unsubmitted awaiting_references application_complete].freeze

  def self.call(provider:)
    ApplicationChoice
    .includes(:course, :provider)
    .where(providers: { code: provider.code })
    .where('status NOT IN (?)', STATES_NOT_VISIBLE_TO_PROVIDER)
  end
end
