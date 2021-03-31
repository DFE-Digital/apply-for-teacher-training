module RegisterAPISpecHelper
  def get_api_request(url, token:, options: {})
    headers_and_params = {
      headers: {
        'Authorization' => "Bearer #{token}",
      },
    }.deep_merge(options)

    get url, **headers_and_params
  end

  def register_api_token
    @register_api_token ||= ServiceAPIUser.register_user.create_magic_link_token!
  end

  def parsed_response
    JSON.parse(response.body)
  end

  def error_response
    parsed_response['errors'].first
  end
end
