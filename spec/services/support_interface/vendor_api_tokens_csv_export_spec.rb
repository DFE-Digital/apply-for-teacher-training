require 'rails_helper'

RSpec.describe SupportInterface::VendorAPITokensCSVExport do
  describe '.call' do
    it 'generates a CSV for vendor api tokens' do
      token = create(:vendor_api_token)
      provider = token.provider

      export = described_class.call(vendor_tokens: [token])

      expect(export).to eq(
        "Provider,Vendor,Tokens issued,Provider user email addresses\n" \
        "#{provider.name},#{provider.vendor_name},#{provider.vendor_api_tokens.count},#{provider.provider_users&.map(&:email_address)&.join(', ')}\n",
      )
    end
  end
end
