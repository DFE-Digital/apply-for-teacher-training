module FindAPI
  class Resource < JsonApiClient::Resource
    self.site = ENV.fetch('FIND_BASE_URL')
    self.connection_options = { headers: { user_agent: 'Apply for teacher training' } }
  end
end

require 'faraday/logging/formatter'

class APIRequestLoggingFormatter < Faraday::Logging::Formatter
  # Don't do logging when the request starts
  def request(env); end

  def response(env)
    info('Response') do
      {
        api_request_url: "#{env.method.upcase} #{env.url}",
        response_status: env.status,
        runtime_ms: (env.response_headers['x-runtime'].to_f * 1000).to_i,
      }
    end
  end
end

FindAPI::Resource.connection do |connection|
  connection.use Faraday::Response::Logger, Rails.logger, formatter: APIRequestLoggingFormatter
end
