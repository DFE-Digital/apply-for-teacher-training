class FilterApplicationChoicesForProviders
  def self.call(application_choices:, status_filters:)
    return application_choices if status_filters.empty?

    application_choices.where(status: status_filters[:status].values)
  end
end
