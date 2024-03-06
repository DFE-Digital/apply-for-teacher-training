require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/confirm-enrolment' do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it_behaves_like 'an endpoint that requires metadata', '/confirm-enrolment'

  it 'is a noop' do
    application_choice = create_application_choice_for_currently_authenticated_provider({}, :recruited)

    post_api_request "/api/v1.0/applications/#{application_choice.id}/confirm-enrolment"

    expect(response).to have_http_status(:ok)
    expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse', '1.0')
    expect(parsed_response['data']['attributes']['status']).to eq 'recruited'
  end

  it 'notifies Sentry' do
    application_choice = create_application_choice_for_currently_authenticated_provider({}, :recruited)

    allow(Sentry).to receive(:capture_exception)

    post_api_request "/api/v1.0/applications/#{application_choice.id}/confirm-enrolment"

    expect(Sentry).to have_received(:capture_exception)
  end

  it 'returns a NotFoundResponse when the application was not found' do
    post_api_request '/api/v1.0/applications/non-existent-id/confirm-enrolment'

    expect(response).to have_http_status(:not_found)
    expect(parsed_response).to contain_schema_with_error('NotFoundResponse', 'Unable to find Applications')
  end
end
