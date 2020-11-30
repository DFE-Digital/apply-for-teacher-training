module FindAPI
  class Resource < JsonApiClient::Resource
    self.site = ENV.fetch('FIND_BASE_URL')
    self.connection_options = { headers: { user_agent: 'Apply for teacher training' } }
  end
end

FindAPI::Resource.connection do |connection|
  connection.use Faraday::Response::Logger, Rails.logger, formatter: APIRequestLoggingFormatter
end
