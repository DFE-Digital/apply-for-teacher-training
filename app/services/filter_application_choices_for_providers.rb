class FilterApplicationChoicesForProviders
  def self.call(application_choices:, filters:)
    return application_choices if filters.empty?

    applied_filters = calculate_applied_filters(filters)

    create_filter_query(application_choices, applied_filters, filters)
  end

  class << self
  private

    def prepare_search_array(search_terms)
      search_terms.downcase.gsub(/\W /, '').split
    end

    def search(application_choices, candidates_name)
      search_array = prepare_search_array(candidates_name)
      application_choices.where('first_name ILIKE ANY (array[?])', search_array)
        .or(application_choices.where('last_name ILIKE ANY (array[?])', search_array))
    end

    def status(application_choices, filters)
      application_choices.where(status: filters[:status].keys)
    end

    def provider(application_choices, filters)
      application_choices.where('courses.provider_id' => filters[:provider].keys)
    end

    def search_exists?(filters)
      filters.fetch(:search, {}).fetch(:candidates_name, "").empty? ? false : true
    end

    def prepare_search_array(search_terms)
      search_terms.downcase.gsub(/\W /, '').split
    end

    def create_filter_query(application_choices, applied_filters, filters)
      filtered_application_choices = application_choices
      filtered_application_choices = search(filtered_application_choices) if search_exists?(filters)
      filtered_application_choices = provider(filtered_application_choices) if filters[:provider]
      filtered_application_choices = status(filtered_application_choices) if filters[:status]
      filtered_application_choices
    end

  end
end
