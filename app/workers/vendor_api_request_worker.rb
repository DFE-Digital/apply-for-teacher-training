class VendorAPIRequestWorker
  include Sidekiq::Worker
  sidekiq_options retry: 3, queue: :low_priority

  def perform(request_data, response_body, status_code, response_time, created_at)
    request_headers = request_data['headers']
    hashed_token = hashed_auth_token(request_headers.delete('HTTP_AUTHORIZATION'))

    VendorAPIRequest.create(
      request_path: request_data['path'],
      request_headers: request_headers,
      request_body: request_data['params'],
      response_body: response_hash(response_body, status_code),
      status_code: status_code,
      response_time: response_time,
      hashed_token: hashed_token,
      created_at: created_at,
    )
  end

private

  def hashed_auth_token(auth_header)
    return if auth_header.blank?

    token = auth_header[7..-1]
    Devise.token_generator.digest(VendorAPIToken, :hashed_token, token)
  end

  def response_hash(response_body, status)
    return {} unless status > 299

    JSON.parse(response_body)
  rescue JSON::ParserError
    { body: "#{status} did not respond with JSON" }
  end
end
