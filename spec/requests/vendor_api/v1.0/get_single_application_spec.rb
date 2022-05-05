require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1.0/applications/:application_id', type: :request do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it 'returns a response that is valid according to the OpenAPI schema' do
    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'awaiting_provider_decision',
    )

    get_api_request "/api/v1.0/applications/#{application_choice.id}"

    expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
  end

  it 'returns a NotFoundResponse if the application cannot be found' do
    get_api_request '/api/v1.0/applications/asu7dvt87asd'

    expect(response).to have_http_status(:not_found)
    expect(parsed_response).to contain_schema_with_error('NotFoundResponse', 'Unable to find Application(s)')
  end

  it 'returns a NotFoundResponse if the application does not belong to the provider' do
    application_choice = create(:application_choice)

    get_api_request "/api/v1.0/applications/#{application_choice.id}"

    expect(response).to have_http_status(:not_found)
    expect(parsed_response).to contain_schema_with_error('NotFoundResponse', 'Unable to find Application(s)')
  end
end
