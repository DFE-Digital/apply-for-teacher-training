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

    def calculate_applied_filters(filters)
      search = search_exists?(filters)
      status = filters[:status] ? true : false
      provider = filters[:provider] ? true : false

      [search, status, provider]
    end

    def search_exists?(filters)
      filters.fetch(:search, {}).fetch(:candidates_name, "").empty? ? false : true
    end

    def prepare_search_array(search_terms)
      search_terms.downcase.gsub(/\W /, '').split
    end

    def create_filter_query(application_choices, applied_filters, filters)
      candidates_name = filters[:search][:candidates_name] if search_exists?(filters)

      case applied_filters
      when options[:provider]
        return provider(application_choices, filters)

      when options[:status]
        return status(application_choices, filters)

      when options[:status_and_provider]
        return provider(status(application_choices, filters), filters)

      when options[:search]
        return search(application_choices, candidates_name)

      when options[:search_and_provider]
        return provider(search(application_choices, candidates_name), filters)

      when options[:search_and_status]
        return search(status(application_choices, filters), candidates_name)

      when options[:search_status_and_provider]
        return provider(search(application_choices, candidates_name), filters)
      else
        return application_choices
      end
    end

    def options
      # mirrors a three variable boolean truth table
      # minus all false as this is caught by default
      {
        provider: [false, false, true],
        status: [false, true, false],
        status_and_provider: [false, true, true],
        search: [true, false, false],
        search_and_provider: [true, false, true],
        search_and_status: [true, true, false],
        search_status_and_provider: [true, true, true],
      }
    end
  end
end
