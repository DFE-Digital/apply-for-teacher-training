require 'rails_helper'

RSpec.describe SupportInterface::VendorAPITokenFilter do
  describe '#filtered_tokens' do
    it 'returns tokens for vendor 1 when filtering by vendor 1' do
      vendor1 = create(:vendor, name: 'vendor1')
      vendor2 = create(:vendor, name: 'vendor2')
      provider1 = create(:provider, vendor: vendor1)
      provider2 = create(:provider, vendor: vendor2)
      token1 = create(:vendor_api_token, provider: provider1)
      token2 = create(:vendor_api_token, provider: provider2)

      filter = described_class.new(filter_params: { vendor_ids: [vendor1.id] })

      expect(filter.filtered_tokens).to eq [token1]
      expect(filter.filtered_tokens).not_to eq [token2]
    end

    it 'returns all tokens if there are no filters' do
      vendor1 = create(:vendor, name: 'vendor1')
      vendor2 = create(:vendor, name: 'vendor2')
      provider1 = create(:provider, vendor: vendor1)
      provider2 = create(:provider, vendor: vendor2)
      token1 = create(:vendor_api_token, provider: provider1)
      token2 = create(:vendor_api_token, provider: provider2)

      filter = described_class.new(filter_params: { vendor_ids: [] })

      expect(filter.filtered_tokens).to eq [token1, token2]
    end
  end

  describe '#filters' do
    it 'returns the filters hash' do
      vendor1 = create(:vendor, name: 'vendor1')
      vendor2 = create(:vendor, name: 'vendor2')

      filter = described_class.new(filter_params: {})

      expect(filter.filters).to eq(
        [
          {
            type: :checkboxes,
            heading: 'Vendors',
            name: 'vendor_ids',
            options: [
              {
                value: vendor1.id,
                label: vendor1.name,
                checked: nil,
              },
              {
                value: vendor2.id,
                label: vendor2.name,
                checked: nil,
              },
            ],
          },
        ],
      )
    end
  end
end
