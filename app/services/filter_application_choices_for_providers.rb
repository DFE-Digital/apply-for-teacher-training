class FilterApplicationChoicesForProviders
  def self.call(application_choices:, filter_options:)
    return application_choices if filter_options.empty?

    application_choices.where(status: filter_options)
  end
end
