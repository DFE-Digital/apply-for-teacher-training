require 'rails_helper'

RSpec.describe 'Vendor API - POST /api/v1/test-data/regenerate', :sidekiq do
  include VendorAPISpecHelpers

  it 'returns an error' do
    post_api_request '/api/v1.0/test-data/regenerate'

    expect(response).to have_http_status(:ok)
    expect(parsed_response['errors'][0]['error'])
      .to eq('Functionality for this endpoint has been removed. Please use /test-data/clear and /test-data/generate.')
  end
end
