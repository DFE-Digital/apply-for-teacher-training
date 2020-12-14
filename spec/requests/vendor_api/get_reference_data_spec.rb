require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1/reference-data', type: :request do
  include VendorAPISpecHelpers

  describe '/gcse-subjects' do
    before do
      get_api_request '/api/v1/reference-data/gcse-subjects'
    end

    it 'returns a response that is valid according to the OpenAPI schema' do
      expect(parsed_response).to be_valid_against_openapi_schema('ListResponse')
    end

    it 'includes GCSE subjects' do
      expect(parsed_response['data']).to include('English')
    end
  end
end
