require 'rails_helper'

RSpec.describe 'Vendor API - headers for all requests', type: :request do
  include VendorAPISpecHelpers

  it 'does not include Feature-Policy headers' do
    get_api_request "/api/v1/applications?since=#{CGI.escape(1.day.ago.iso8601)}"

    expect(response.headers['Feature-Policy']).not_to be_present
  end
end
