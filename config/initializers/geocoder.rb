Geocoder.configure(
  timeout: 3,                         # geocoding service timeout (secs)
  lookup: :google,                    # name of geocoding service (symbol)
  use_https: true, # use HTTPS for lookup requests? (if supported)
  api_key: Settings.google.gcp_api_key, # API key for geocoding service

  # Exceptions that should not be rescued by default
  # (if you want to implement custom error handling);
  # supports SocketError and Timeout::Error
  always_raise: [Geocoder::InvalidApiKey, Geocoder::OverQueryLimitError],

  units: :mi, # :km for kilometers or :mi for miles
)
