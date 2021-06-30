require 'rails_helper'

RSpec.describe SupportInterface::VendorAPIRequestDetailsComponent do
  it 'renders Unknown for an unknown provider' do
    req = build(:vendor_api_request, provider: nil)

    component = render_inline(described_class.new(req))

    expect(component.text).to include('Unknown')
  end

  it 'includes a link to the application if the request identifies a single application' do
    req = build(:vendor_api_request, request_path: '/api/v1/applications/11/offer')

    component = render_inline(described_class.new(req))
    link_to_application = component.at_css('a:contains("View in support")')

    expect(link_to_application).to be_present
    expect(link_to_application['href']).to match(/\/support\/application-choices\/11/)
  end

  it 'does not includes a link to the application if the request does not identify a single application' do
    req = build(:vendor_api_request, request_path: '/api/v1/applications')

    component = render_inline(described_class.new(req))

    expect(component.at_css('a:contains("View in support")')).not_to be_present
  end
end
