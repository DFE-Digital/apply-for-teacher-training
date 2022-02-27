RSpec.shared_context 'Vendor API Spec Helpers' do
  let(:api_token) { VendorAPIToken.create_with_random_token!(provider: currently_authenticated_provider) }
  let(:currently_authenticated_provider) { create(:provider) }
  let(:auth_header) { "Bearer #{api_token}" }
end

module VendorAPISpecHelpers
  RSpec.configure do |config|
    config.include_context 'Vendor API Spec Helpers'
  end

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

  def create_application_choice_for_currently_authenticated_provider(attributes = {}, traits = nil)
    course = build(:course, provider: currently_authenticated_provider)
    course_option = build(:course_option, course: course)
    create(:submitted_application_choice,
           :with_completed_application_form,
           *traits,
           { course_option: course_option }.merge(attributes))
  end

  def parsed_response
    JSON.parse(response.body)
  end

  def error_response
    parsed_response['errors'].first
  end

  def be_valid_against_openapi_schema(expected, version = nil, draft: false)
    ValidAgainstOpenAPISchemaMatcher.new(expected, VendorAPISpecification.new(version: version, draft: draft).as_hash)
  end

  def be_valid_against_draft_openapi_schema(expected, version = nil)
    be_valid_against_openapi_schema(expected, version, draft: true)
  end

  RSpec::Matchers.define :contain_schema_with_error do |schema, message, version = nil, draft = false|
    match do |actual|
      ValidAgainstOpenAPISchemaMatcher.new(schema,
                                           VendorAPISpecification.new(version: version,
                                                                      draft: draft).as_hash).matches?(actual)
      (actual['errors'].map { |error| error['message'] } - [message]).empty?
    end
  end
end
