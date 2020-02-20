class FilterApplicationChoicesForProviders
  def self.call(application_choices:, page_state:)
    return application_choices if page_state.filter_options.empty?

    application_choices.where(status: page_state.filter_options)
  end
end
