require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1/test-data/regenerate', type: :request do
  include VendorApiSpecHelpers

  it 'generates test data' do
    post_api_request '/api/v1/test-data/regenerate?count=3'

    expect(Candidate.count).to be(3)
    expect(parsed_response).to be_valid_against_openapi_schema('OkResponse')
  end

  it 'does not generate test data in production' do
    ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'production' do
      post_api_request '/api/v1/test-data/regenerate?count=3'
    end

    expect(Candidate.count).to be(0)
    expect(response.code).to eql '400'
    expect(parsed_response).to be_valid_against_openapi_schema('OkResponse')
  end
end
