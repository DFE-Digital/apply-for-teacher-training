require 'rails_helper'

RSpec.describe 'API Docs - GET /api-docs/reference', type: :request do
  VendorAPI::VERSIONS.each_key do |version|
    before { stub_const('VendorAPI::VERSION', version) }

    it "returns paths and components for version #{version}" do
      get '/api-docs/reference'

      expect(response).to have_http_status(:ok)
      expect(response.body).to match 'API reference'
      expect(response.body).to match 'GET /applications'
      expect(response.body).to match 'MultipleApplicationsResponse'
    end
  end

  it 'returns paths and components for the draft version' do
    FeatureFlag.activate(:draft_vendor_api_specification)

    get '/api-docs/draft'

    expect(response).to have_http_status(:ok)
    expect(response.body).to match 'This API spec is currently a draft'
    expect(response.body).to match 'GET /applications'
    expect(response.body).to match 'MultipleApplicationsResponse'
  end
end
