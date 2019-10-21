require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/reject', type: :request do
  include VendorApiSpecHelpers
  include CourseOptionHelpers

  it_behaves_like 'an endpoint that requires metadata', '/reject'

  describe 'successfully rejecting an application' do
    it 'returns rejected application' do
      application_choice = create_application_choice_for_currently_authenticated_provider(status: 'application_complete')
      request_body = {
        "data": {
          "reason": 'Does not meet minimum GCSE requirements',
        },
      }

      post_api_request "/api/v1/applications/#{application_choice.id}/reject", params: request_body

      expect(response).to have_http_status(200)
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq 'rejected'
      expect(parsed_response['data']['attributes']['rejection']).to match a_hash_including(
        'reason' => 'Does not meet minimum GCSE requirements',
        'date' => anything, # This is not implemented yet
      )
    end
  end

  it 'returns an error when trying to transition to an invalid state' do
    application_choice = create_application_choice_for_currently_authenticated_provider(status: 'rejected')

    post_api_request "/api/v1/applications/#{application_choice.id}/reject", params: {}

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
  end

  it 'returns an error when a proper reason is not provided' do
    application_choice = create_application_choice_for_currently_authenticated_provider(status: 'application_complete')

    post_api_request "/api/v1/applications/#{application_choice.id}/reject", params: {
      data: {
        reason: '',
      },
    }

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
    expect(error_response['message']).to eql "Rejection reason can't be blank"
  end


  it 'returns not found error when the application was not found' do
    post_api_request '/api/v1/applications/non-existent-id/reject'

    expect(response).to have_http_status(404)
    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
    expect(error_response['message']).to eql('Could not find an application with ID non-existent-id')
  end
end
