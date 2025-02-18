class VendorAPIRequestWorker
  AuthorizationStruct = Struct.new(:authorization)

  include Sidekiq::Worker
  include ActionController::HttpAuthentication::Token

  sidekiq_options retry: 3, queue: :low_priority

  def perform(request_data, response_data, status_code, created_at)
    request_headers = request_data.fetch('headers', {})
    provider_id = provider_id_from_auth_token(request_headers.delete('HTTP_AUTHORIZATION'))

    # FIXME: Temporary measure to ensure any existing background jobs will populate records correctly.
    # This can be simplified once middleware is enqueuing response headers and body in the response_data param.
    if response_data.is_a?(Hash)
      response_headers = response_data['headers']
      response_body = response_data['body']
    else
      response_headers = nil
      response_body = response_data
    end

    VendorAPIRequest.create!(
      request_path: request_data['path'],
      request_headers:,
      request_body: request_body(request_data),
      request_method: request_data['method'],
      response_headers:,
      response_body: response_hash(response_body, status_code),
      status_code:,
      provider_id:,
      created_at:,
    )
  end

private

  def provider_id_from_auth_token(auth_header)
    return if auth_header.blank?

    token, _options = token_and_options(AuthorizationStruct.new(auth_header))
    VendorAPIToken.find_by_unhashed_token(token)&.provider_id
  end

  def response_hash(response_body, status)
    return {} unless status > 299

    JSON.parse(response_body)
  rescue JSON::ParserError
    { body: "#{status} did not respond with JSON" }
  end

  def request_body(request_data)
    if request_data['method'] == 'POST'
      return if request_data['body'].blank?

      JSON.parse(request_data['body'])
    else
      request_data['params']
    end
  rescue JSON::ParserError
    { error: 'request data did not contain valid JSON' }
  end
end
