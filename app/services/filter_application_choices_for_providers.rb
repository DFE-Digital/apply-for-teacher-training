class FilterApplicationChoicesForProviders
  def self.call(application_choices:, filters:)
    return application_choices if filters.empty?

    if filters[:status] && filters[:provider]
      application_choices.where(status: filters[:status].keys, 'courses.provider_id' => filters[:provider].keys)
    elsif filters[:status]
      application_choices.where(status: filters[:status].keys)
    else
      application_choices.where('courses.provider_id' => filters[:provider].keys)
    end
  end
end
