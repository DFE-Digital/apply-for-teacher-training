class FilterApplicationChoicesForProviders
  def self.call(application_choices:, filters:)
    return application_choices if filters.empty?

      if filters[:status] && filters[:provider]
        return application_choices.where(status: page_state.filter_options, 'courses.provider_id' => provider_options)
      elsif filters[:status]
        return application_choices.where(status: filters[:status].values)
      else
        application_choices.where('courses.provider_id' => filters[:provider].values)
      end
  end
end
