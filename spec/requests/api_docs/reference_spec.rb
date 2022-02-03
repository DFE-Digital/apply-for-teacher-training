require 'rails_helper'

RSpec.describe 'API Docs - GET /api-docs/reference', type: :request do
  include Capybara::RSpecMatchers

  VendorAPI::VERSIONS.each_key do |version|
    it "returns paths and components for version #{version}" do
      stub_const('VendorAPI::VERSION', version)

      get "/api-docs/v#{version}/reference"

      expect(response).to have_http_status(:ok)
      expect(response.body).to match 'API reference'
      expect(response.body).to match 'GET /applications'
      expect(response.body).to match 'MultipleApplicationsResponse'
    end
  end

  it 'redirects /api-docs/reference to the current version docs' do
    get '/api-docs/reference'

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to("/api-docs/v#{VendorAPI::VERSION}/reference")
  end

  it 'renders version navigation when more than one version is available' do
    stub_const('AllowedCrossNamespaceUsage::VENDOR_API_VERSION', '1.1')

    get '/api-docs/v1.1/reference'

    expect(response).to have_http_status(:ok)
    expect(response.body).to have_link '1.0', href: '/api-docs/v1.0/reference'
    expect(response.body).to have_link '1.1', href: '/api-docs/v1.1/reference'
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
