class VendorAPIRequestWorker
  include Sidekiq::Worker
  include ActionController::HttpAuthentication::Token

  sidekiq_options retry: 3, queue: :low_priority

  def perform(request_data, response_body, status_code, created_at)
    request_headers = request_data['headers']
    provider_id = provider_id_from_auth_token(request_headers.delete('HTTP_AUTHORIZATION'))

    VendorAPIRequest.create!(
      request_path: request_data['path'],
      request_headers: request_headers,
      request_body: request_data['params'],
      response_body: response_hash(response_body, status_code),
      status_code: status_code,
      provider_id: provider_id,
      created_at: created_at,
    )
  end

private

  AuthorizationStruct = Struct.new(:authorization)

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
end
