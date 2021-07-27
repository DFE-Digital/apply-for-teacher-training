require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/confirm-enrolment', type: :request do
  include VendorAPISpecHelpers
  include CourseOptionHelpers

  it_behaves_like 'an endpoint that requires metadata', '/confirm-enrolment'

  it 'is a noop' do
    application_choice = create_application_choice_for_currently_authenticated_provider(status: 'recruited')

    post_api_request "/api/v1/applications/#{application_choice.id}/confirm-enrolment"

    expect(response).to have_http_status(:ok)
    expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
    expect(parsed_response['data']['attributes']['status']).to eq 'recruited'
  end

  it 'notifies Sentry' do
    application_choice = create_application_choice_for_currently_authenticated_provider(status: 'recruited')

    allow(Sentry).to receive(:capture_exception)

    post_api_request "/api/v1/applications/#{application_choice.id}/confirm-enrolment"

    expect(Sentry).to have_received(:capture_exception)
  end

  it 'returns a not found error when the application was not found' do
    post_api_request '/api/v1/applications/non-existent-id/confirm-enrolment'

    expect(response).to have_http_status(:not_found)
    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
    expect(error_response['message']).to eql('Could not find an application with ID non-existent-id')
  end
end
