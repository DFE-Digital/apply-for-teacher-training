require 'rails_helper'

RSpec.describe 'Vendor API throttling', rack_attack: true do
  include VendorAPISpecHelpers

  it 'returns 429 responses when the rate limit is exceeded' do
    VENDOR_API_MAX_REQS_PER_MINUTE.times do
      get_api_request '/api/v1/applications?since=2021-01-01T12:00:00Z'
    end

    expect(response).to have_http_status(:success)

    get_api_request '/api/v1/applications?since=2021-01-01T12:00:00Z'
    expect(response).to have_http_status(:too_many_requests)

    Timecop.travel(1.minute.from_now) do
      get_api_request '/api/v1/applications?since=2021-01-01T12:00:00Z'
      expect(response).to have_http_status(:success)
    end
  end

  it 'does not apply to other paths' do
    VENDOR_API_MAX_REQS_PER_MINUTE.times do
      get_api_request '/provider'
    end

    get_api_request '/provider'
    expect(response).to have_http_status(:success)
  end
end
