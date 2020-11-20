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
