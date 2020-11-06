module FindInterface::ResultFilters
  class LocationFilterForm
    NO_OPTION = nil
    LOCATION_OPTION = "1".freeze

    attr_reader :params, :errors

    def initialize(params)
      @params = params
      @errors = []
    end

    def valid?
      validate
      @errors.empty?
    end

  private

    def validate
      case selected_option
      when NO_OPTION
        @errors = [I18n.t("location_filter.errors.no_option")]
      when LOCATION_OPTION
        if location_query.nil?
          @errors = [I18n.t("location_filter.fields.location"), I18n.t("location_filter.errors.missing_location")]
        else
          handle_location_option
        end
      end
    end

    def handle_location_option
      geocode_params = geocode_params_for(location_query)
      if geocode_params
        @params.merge!(geocode_params)
        @valid = true
      else
        @errors = [I18n.t("location_filter.fields.location"), I18n.t("location_filter.errors.unknown_location")]
      end
    end

    def geocode_params_for(query)
      results = Geocoder.search(query, components: "country:UK").first
      if results
        {
          lat: results.latitude,
          lng: results.longitude,
          loc: results.address,
          lq: location_query,
        }
      end
    end

    def selected_option
      @params[:l]
    end

    def location_query
      @params[:lq]
    end

    def search_radius
      @params[:rad]
    end
  end
end
