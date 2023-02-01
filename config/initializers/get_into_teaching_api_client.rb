GetIntoTeachingApiClient.configure do |config|
  endpoint = ENV['GET_INTO_TEACHING_API_URL'].presence

  if endpoint
    parsed = URI.parse(endpoint)
    config.host = parsed.hostname
  end

  config.api_key['apiKey'] = ENV['GET_INTO_TEACHING_API_KEY'].presence
  config.server_index = nil
  config.api_key_prefix['apiKey'] = 'Bearer'
  config.scheme = 'https'
  config.cache_store = Rails.cache
end
