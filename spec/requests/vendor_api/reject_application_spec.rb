require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/reject', type: :request do
  include VendorApiSpecHelpers

  let(:valid_metadata) {
    {
      attribution: {
        full_name: 'Jane Smith',
        email: 'jane@example.com',
        user_id: '12345',
      },
      timestamp: Time.now.iso8601,
    }
  }

  it_behaves_like 'an endpoint that requires metadata', '/reject'

  describe 'successfully rejecting an application' do
    it 'returns rejected application' do
      application_choice = create(:application_choice)
      request_body = {
        "data": {
          "reason": 'Does not meet minimum GCSE requirements',
          "timestamp": '2019-03-01T15:33:49.216Z',
        },
      }.merge(meta: valid_metadata)

      post_api_request "/api/v1/applications/#{application_choice.id}/reject", params: request_body

      expect(response).to have_http_status(200)
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq 'rejected'
      expect(parsed_response['data']['attributes']['rejection']).to eq(
        'reason' => 'Does not meet minimum GCSE requirements',
        'date' => '2019-03-01T15:33:49.216Z',
      )
    end
  end

  it 'returns an error when trying to transition to an invalid state' do
    application_choice = create(:application_choice, status: 'rejected')

    post_api_request "/api/v1/applications/#{application_choice.id}/reject", params: {}

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
  end

  it 'returns not found error when the application was not found' do
    post_api_request '/api/v1/applications/non-existent-id/reject'

    expect(response).to have_http_status(404)
    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
    expect(error_response['message']).to eql('Could not find an application with ID non-existent-id')
  end
end
