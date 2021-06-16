module CandidateAPISpecHelper
  def get_api_request(url, token:, options: {})
    headers_and_params = {
      headers: {
        'Authorization' => "Bearer #{token}",
      },
    }.deep_merge(options)

    get url, **headers_and_params
  end

  def candidate_api_token
    @candidate_api_token ||= ServiceAPIUser.candidate_user.create_magic_link_token!
  end

  def parsed_response
    JSON.parse(response.body)
  end

  def error_response
    parsed_response['errors'].first
  end

  def be_valid_against_openapi_schema(expected)
    ValidAgainstOpenAPISchemaMatcher.new(expected, CandidateAPISpecification.as_hash)
  end
end
