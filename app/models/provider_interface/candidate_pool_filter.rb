module ProviderInterface
  class CandidatePoolFilter
    include FilterParamsHelper

    RADIUS_VALUES = [1, 5, 10, 15, 20, 25, 50, 100, 200].freeze

    attr_reader :filter_params

    def initialize(filter_params:)
      @filter_params = compact_params(filter_params)
    end

    def filters
      [
        {
          type: :location_search,
          heading: 'Search radius',
          name: 'location_search',
          hint: "Candidate's last course location",
          radius_values: RADIUS_VALUES,
          select_value: filter_params[:within],
          location_value: filter_params[:original_location],
        },
        {
          type: :checkboxes,
          heading: 'Visa sponsorship',
          name: 'visa_sponsorship',
          options: visa_sponsorship_options,
        },
      ]
    end

    def visa_sponsorship_options
      ['required', 'not required'].map do |value|
        {
          value: value,
          label: value.capitalize,
          checked: applied_filters[:visa_sponsorship]&.include?(value),
        }
      end
    end

    def applied_filters
      if filter_params[:within].present? && filter_params[:original_location].present?
        geocoder_location = Geocoder.search(filter_params[:original_location], components: 'country:UK').first

        return filter_params unless geocoder_location

        filter_params.merge!(
          {
            origin: [
              geocoder_location.latitude,
              geocoder_location.longitude,
            ],
            within: filter_params[:within],
          },
        )
      end

      filter_params
    end
  end
end
