class FilterApplicationChoicesForProviders
  def self.call(application_choices:, filters:)
    return application_choices if filters.empty?

    application_choices.where(status: filters[:status].values)
  end
end
