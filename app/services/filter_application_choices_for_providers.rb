class FilterApplicationChoicesForProviders
  def self.call(application_choices:, filters:)
    return application_choices if filters.empty?

    if filters[:status] && filters[:provider]
      application_choices.where(status: filters[:status].values, 'courses.provider_id' => filters[:provider].values)
    elsif filters[:status]
      application_choices.where(status: filters[:status].values)
    else
      application_choices.where('courses.provider_id' => filters[:provider].values)
    end
  end
end
