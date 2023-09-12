require 'rails_helper'

RSpec.describe 'Vendor API throttling', :rack_attack do
  include VendorAPISpecHelpers

  # Calling Rack::Attack.cache.count will increment the current request count
  # value and return it. (The cache key is calculated according to private
  # logic in Rack::Attack::Cache). This means we can prove whether a request
  # was eligible for throttling by testing whether or not it bumped the count.
  it 'counts requests to Vendor API paths' do
    get_api_request '/api/v1/applications?since=2021-01-01T12:00:00Z'

    expect(Rack::Attack.cache.count('vendor_api/ip:127.0.0.1', 1.minute)).to eq 2
  end

  it 'counts requests to Vendor API with minor versions' do
    get_api_request '/api/v1.1/applications?since=2021-01-01T12:00:00Z'

    expect(Rack::Attack.cache.count('vendor_api/ip:127.0.0.1', 1.minute)).to eq 2
  end

  it 'does not count requests to other paths' do
    get_api_request '/provider'

    expect(Rack::Attack.cache.count('vendor_api/ip:127.0.0.1', 1.minute)).to eq 1
  end
end
