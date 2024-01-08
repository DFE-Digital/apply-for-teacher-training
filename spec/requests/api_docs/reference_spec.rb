require 'rails_helper'

RSpec.describe 'API Docs - GET /api-docs/reference' do
  include Capybara::RSpecMatchers

  VendorAPI::VERSIONS.each_key do |version|
    it "returns paths and components for version #{version}" do
      stub_const('VendorAPI::VERSION', version)

      get api_docs_versioned_reference_path("v#{VendorAPI.full_version_number_from(version)}")

      expect(response).to have_http_status(:ok)
      expect(response.body).to match 'API reference'
      expect(response.body).to match 'GET /applications'
      expect(response.body).to match 'MultipleApplicationsResponse'
    end
  end

  it 'redirects /api-docs/reference to the current production released version docs' do
    stub_const('VendorAPI::VERSION', '1.1')
    stub_const('VendorAPI::VERSIONS', { '1.0' => [], '1.1pre' => [] })

    get api_docs_reference_path

    expect(response).to have_http_status(:moved_permanently)
    expect(response).to redirect_to('/api-docs/v1.0/reference')
  end

  it 'renders version navigation when more than one version is available' do
    stub_const('VendorAPI::VERSION', '1.0')
    stub_const('VendorAPI::VERSIONS', { '1.0' => [], '1.1' => [] })

    get api_docs_versioned_reference_path('v1.0')

    expect(response.body).to have_link '1.0', href: '/api-docs/v1.0/reference'
    expect(response.body).to have_link '1.1', href: '/api-docs/v1.1/reference'
  end

  it 'does not make prerelease versions available' do
    stub_const('VendorAPI::VERSION', '1.2')
    stub_const('VendorAPI::VERSIONS', { '1.0' => [], '1.1' => [], '1.2pre' => [] })

    get api_docs_versioned_reference_path('v1.0')

    expect(response.body).to have_link '1.0', href: '/api-docs/v1.0/reference'
    expect(response.body).to have_link '1.1', href: '/api-docs/v1.1/reference'
    expect(response.body).to have_no_link '1.2', href: '/api-docs/v1.1/reference'
  end

  it 'returns paths and components for the draft version' do
    FeatureFlag.activate(:draft_vendor_api_specification)

    get api_docs_draft_path

    expect(response).to have_http_status(:ok)
    expect(response.body).to match 'This API spec is currently a draft'
    expect(response.body).to match 'GET /applications'
    expect(response.body).to match 'MultipleApplicationsResponse'
  end
end
