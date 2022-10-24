require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1.0/experimental/test-data/*' do
  include VendorAPISpecHelpers

  it 'responds with 410 Gone' do
    post_api_request('/api/v1.0/experimental/test-data/clear')
    expect(response).to have_http_status(:gone)

    post_api_request('/api/v1.0/experimental/test-data/generate')
    expect(response).to have_http_status(:gone)
  end

  it 'responds with a message containing the new endpoint path' do
    post_api_request('/api/v1.0/experimental/test-data/clear')
    expect(parsed_response['data']['message']).to include('has moved to /api/v1.0/test-data/clear')

    post_api_request('/api/v1.0/experimental/test-data/generate')
    expect(parsed_response['data']['message']).to include('has moved to /api/v1.0/test-data/generate')
  end
end
