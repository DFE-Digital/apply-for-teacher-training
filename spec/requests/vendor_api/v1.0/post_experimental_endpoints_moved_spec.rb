require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1/experimental/test-data/*', type: :request do
  include VendorAPISpecHelpers

  it 'responds with 410 Gone' do
    post_api_request('/api/v1/experimental/test-data/clear')
    expect(response.status).to eq(410)

    post_api_request('/api/v1/experimental/test-data/generate')
    expect(response.status).to eq(410)
  end

  it 'responds with a message containing the new endpoint path' do
    post_api_request('/api/v1/experimental/test-data/clear')
    expect(parsed_response['data']['message']).to include('has moved to /api/v1/test-data/clear')

    post_api_request('/api/v1/experimental/test-data/generate')
    expect(parsed_response['data']['message']).to include('has moved to /api/v1/test-data/generate')
  end
end
