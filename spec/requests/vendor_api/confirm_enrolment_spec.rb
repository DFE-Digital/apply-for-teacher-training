require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/confirm-enrolment', type: :request do
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

  describe 'successfully confirming enrolment' do
    it 'returns updated application' do
      application_choice = create(:application_choice, status: 'recruited')

      post_api_request "/api/v1/applications/#{application_choice.id}/confirm-enrolment",
                       params: { meta: valid_metadata }

      expect(response).to have_http_status(200)
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
      expect(parsed_response['data']['attributes']['status']).to eq 'enrolled'
    end
  end

  it 'returns an error when Metadata is not provided' do
    application_choice = create(:application_choice)

    post_api_request "/api/v1/applications/#{application_choice.id}/confirm-enrolment"

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('BadRequestBodyResponse')
  end

  it 'returns an error when Metadata is invalid' do
    application_choice = create(:application_choice)

    invalid_metadata = { invalid: :metadata }

    post_api_request "/api/v1/applications/#{application_choice.id}/confirm-enrolment",
                     params: { meta: invalid_metadata }

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('BadRequestBodyResponse')
  end

  it 'returns not found error when the application was not found' do
    post_api_request '/api/v1/applications/non-existent-id/confirm-enrolment',
                     params: { meta: valid_metadata }

    expect(response).to have_http_status(404)
    expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
    expect(error_response['message']).to eql('Could not find an application with ID non-existent-id')
  end

  it 'returns an error when trying to transition to an invalid state' do
    application_choice = create(:application_choice, status: 'rejected')

    post_api_request "/api/v1/applications/#{application_choice.id}/confirm-enrolment",
                     params: { meta: valid_metadata }

    expect(response).to have_http_status(422)
    expect(parsed_response).to be_valid_against_openapi_schema('UnprocessableEntityResponse')
  end
end
