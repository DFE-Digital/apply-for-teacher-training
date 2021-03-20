module DataAPISpecHelper
  def get_api_request(url, token:, options: {})
    headers_and_params = {
      headers: {
        'Authorization' => "Bearer #{token}",
      },
    }.deep_merge(options)

    get url, **headers_and_params
  end

  def tad_api_token
    @tad_api_token ||= ServiceAPIUser.tad_user.create_magic_link_token!
  end

  def parsed_response
    JSON.parse(response.body)
  end

  def be_valid_against_openapi_schema(expected)
    ValidAgainstOpenAPISchemaMatcher.new(expected, DataAPISpecification.as_hash)
  end
end
