module VendorAPISpecHelpers
  VALID_METADATA = {
    attribution: {
      full_name: 'Jane Smith',
      email: 'jane@example.com',
      user_id: '12345',
    },
    timestamp: Time.zone.now.iso8601,
  }.freeze

  def get_api_request(url, options = {})
    headers_and_params = {
      headers: {
        'Authorization' => auth_header,
      },
    }.deep_merge(options)

    get url, **headers_and_params
  end

  def post_api_request(url, options = {})
    headers_and_params = {
      params: {
        meta: VALID_METADATA,
      },
      headers: {
        'Authorization' => auth_header,
        'Content-Type' => 'application/json',
      },
    }.deep_merge(options)

    headers_and_params[:params] = headers_and_params[:params].to_json

    post url, **headers_and_params
  end

  def auth_header
    "Bearer #{api_token}"
  end

  def api_token
    @api_token ||= VendorAPIToken.create_with_random_token!(provider: currently_authenticated_provider)
  end

  def currently_authenticated_provider
    @currently_authenticated_provider ||= create(:provider)
  end

  def create_application_choice_for_currently_authenticated_provider(attributes = {})
    create(
      :submitted_application_choice,
      :with_completed_application_form,
      { course_option: course_option_for_provider(provider: currently_authenticated_provider) }.merge(attributes),
    )
  end

  def parsed_response
    JSON.parse(response.body)
  end

  def error_response
    parsed_response['errors'].first
  end

  def be_valid_against_openapi_schema(expected)
    ValidAgainstOpenAPISchemaMatcher.new(expected, VendorAPISpecification.as_hash)
  end
end
