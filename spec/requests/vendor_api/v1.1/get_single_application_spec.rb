require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1.1/applications/:application_id', type: :request do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  before do
    stub_const('VendorAPI::VERSION', '1.1')
  end

  it 'returns a response that is valid according to the OpenAPI schema' do
    skip 'Depends on validation versions spike'

    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'awaiting_provider_decision',
    )

    get_api_request "/api/v1.1/applications/#{application_choice.id}"

    expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.1')
  end

  it 'includes an interviews section' do
    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'awaiting_provider_decision',
    )

    get_api_request "/api/v1.1/applications/#{application_choice.id}"

    expect(response).to have_http_status(:ok)
    expect(parsed_response['data']['attributes']['interviews']).not_to be_nil
  end

  it 'does not return the links object' do
    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'awaiting_provider_decision',
    )

    get_api_request "/api/v1.1/applications/#{application_choice.id}"

    expect(response).to have_http_status(:ok)
    expect(parsed_response['links']).to be_nil
  end

  it 'returns the correct meta data object' do
    application_choice = create_application_choice_for_currently_authenticated_provider(
      status: 'awaiting_provider_decision',
    )

    get_api_request "/api/v1.1/applications/#{application_choice.id}"

    expect(response).to have_http_status(:ok)
    expect(parsed_response['meta']['version']).to eq 'v1.1'
    expect(parsed_response['meta']['total_count']).to be_nil
  end
end
