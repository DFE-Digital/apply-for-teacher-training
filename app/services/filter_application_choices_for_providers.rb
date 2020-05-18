class FilterApplicationChoicesForProviders
  def self.call(application_choices:, filters:)
    return application_choices if filters.empty?

    create_filter_query(application_choices, filters)
  end

  class << self
  private

    def search(application_choices, candidates_name)
      return application_choices if candidates_name.blank?

      application_choices.where("CONCAT(first_name, ' ', last_name) ILIKE ?", "%#{candidates_name}%")
    end

    def status(application_choices, statuses)
      return application_choices if statuses.blank?

      application_choices.where(status: statuses)
    end

    def provider(application_choices, providers)
      return application_choices if providers.blank?

      application_choices.where('courses.provider_id' => providers)
    end

    def accredited_provider(application_choices, accredited_providers)
      return application_choices if accredited_providers.blank?

      application_choices.where('courses.accredited_provider_id' => accredited_providers)
    end

    def create_filter_query(application_choices, filters)
      filtered_application_choices = search(application_choices, filters[:candidate_name])
      filtered_application_choices = provider(filtered_application_choices, filters[:provider])
      filtered_application_choices = accredited_provider(filtered_application_choices, filters[:accredited_provider])
      filtered_application_choices = status(filtered_application_choices, filters[:status])
      filtered_application_choices
    end
  end
end
