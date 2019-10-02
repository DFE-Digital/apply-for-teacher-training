require 'rails_helper'

RSpec.describe 'Vendor API - POST /applications/:application_id/confirm-enrolment', type: :request do
  include VendorApiSpecHelpers

  context 'when the request is valid' do
    let!(:application_choice) { create(:application_choice) }

    before { post "/api/v1/applications/#{application_choice.id}/confirm-enrolment" }

    it 'returns 200' do
      expect(response).to have_http_status(200)
    end

    it 'returns a response that is valid according to JSON schema' do
      expect(parsed_response).to be_valid_against_openapi_schema('SingleApplicationResponse')
    end

    it 'returns an application with the status "enrolled"' do
      expect(parsed_response['data']['attributes']['status']).to eq 'enrolled'
    end
  end

  context 'when the application was not found' do
    it 'returns not found error - 404' do
      post '/api/v1/applications/non-existent-id/confirm-enrolment'

      expect(response).to have_http_status(404)
      expect(parsed_response).to be_valid_against_openapi_schema('NotFoundResponse')
      expect(error_response['message']).to eql('Could not find an application with ID non-existent-id')
    end
  end
end
