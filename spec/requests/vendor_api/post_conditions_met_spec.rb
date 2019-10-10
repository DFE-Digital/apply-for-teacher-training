require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/confirm-conditions-met', type: :request do
  include VendorApiSpecHelpers

  it_behaves_like 'an endpoint that requires metadata', '/confirm-conditions-met'

  it 'confirms the conditions have been met' do
    application_choice = create(:application_choice, status: 'conditional_offer')

    post_api_request "/api/v1/applications/#{application_choice.id}/confirm-conditions-met"

    expect(response).to have_http_status(200)
    expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
    expect(parsed_response['data']['attributes']['status']).to eq 'recruited'
  end

  it 'returns an error when trying to transition to an invalid state' do
    application_choice = create(:application_choice, status: 'rejected')

    post_api_request "/api/v1/applications/#{application_choice.id}/confirm-conditions-met", params: {}

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
  end

  it 'returns not found error when the application was not found' do
    post_api_request '/api/v1/applications/non-existent-id/confirm-conditions-met'

    expect(response).to have_http_status(404)
    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
    expect(error_response['message']).to eql('Could not find an application with ID non-existent-id')
  end
end
