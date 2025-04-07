module GoogleMapsAPI
  class Client
    BASE_URL = 'https://maps.googleapis.com/maps/api/'.freeze

    attr_reader :api_key, :connection

    def initialize(logger: Rails.logger, log_level: Rails.logger.level)
      @api_key = ENV['GOOGLE_MAPS_API_KEY']
      @connection = Faraday.new(BASE_URL) do |f|
        f.response(:logger, logger, { headers: false, bodies: true, formatter: Faraday::Logging::Formatter, log_level: }) do |log|
          log.filter(api_key, '[FILTERED]')
        end
        f.response :json
      end
    end

    def autocomplete(query)
      response = get(
        endpoint: 'place/autocomplete/json',
        params: {
          key: api_key,
          language: 'en',
          input: query,
          components: 'country:uk',
          types: '(regions)',
        },
      )

      Array(response['predictions']).map do |prediction|
        {
          name: prediction['description'],
          place_id: prediction['place_id'],
          types: prediction['types'],
        }
      end
    end

  private

    def get(endpoint:, params:)
      response = connection.get(endpoint, params)

      response.body || {}
    rescue Faraday::Error => e
      Sentry.capture_message("Google Maps API error - '#{response.status}', '#{response.body}'. Exception: '#{e}'")
      {}
    end
  end
end
