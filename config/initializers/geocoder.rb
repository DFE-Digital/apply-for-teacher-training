Geocoder.configure(
  timeout: 3, # geocoding service timeout (secs)
  lookup: :google, # name of geocoding service (symbol)
  use_https: true, # use HTTPS for lookup requests? (if supported)
  api_key: ENV['GOOGLE_MAPS_API_KEY'], # API key for geocoding service

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  always_raise: [Geocoder::InvalidApiKey, Geocoder::OverQueryLimitError],

  units: :mi, # :km for kilometers or :mi for miles
  cache: Rails.cache,
  cache_options: {
    expiration: 1.day,
  },
)
