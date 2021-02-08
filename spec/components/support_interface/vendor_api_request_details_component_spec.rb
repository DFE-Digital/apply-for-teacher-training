require 'rails_helper'

RSpec.describe SupportInterface::VendorAPIRequestDetailsComponent do
  it 'renders Unknown for an unknown provider' do
    req = build(:vendor_api_request, provider: nil)

    component = render_inline(described_class.new(req))

    expect(component.text).to include('Unknown')
  end
end
