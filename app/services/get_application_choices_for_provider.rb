class GetApplicationChoicesForProvider
  def self.call(provider:)
    states_not_visible_to_provider = %i[unsubmitted awaiting_references]

    ApplicationChoice
    .for_provider(provider.code)
    .where('status NOT IN (?)', states_not_visible_to_provider)
  end
end
