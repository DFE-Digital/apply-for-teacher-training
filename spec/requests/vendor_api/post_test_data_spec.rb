require 'rails_helper'

RSpec.describe 'Vendor API - GET /api/v1/test-data/regenerate', type: :request do
  include VendorApiSpecHelpers

  it 'generates test data' do
    post_api_request '/api/v1/test-data/regenerate?count=3'

    expect(Candidate.count).to be(3)
    expect(parsed_response).to be_valid_against_openapi_schema('OkResponse')
  end
end
