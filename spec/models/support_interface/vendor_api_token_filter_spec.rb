require 'rails_helper'

RSpec.describe SupportInterface::VendorAPITokenFilter do
  describe '#filtered_tokens' do
    it 'returns tokens for vendor 1 when filtering by vendor 1' do
      vendor1 = create(:vendor, name: 'vendor_1')
      vendor2 = create(:vendor, name: 'vendor_2')
      provider1 = create(:provider, vendor: vendor1)
      provider2 = create(:provider, vendor: vendor2)
      token1 = create(:vendor_api_token, provider: provider1)
      token2 = create(:vendor_api_token, provider: provider2)

      filter = described_class.new(filter_params: { vendor_ids: [vendor1.id] })

      expect(filter.filtered_tokens).to eq [token1]
      expect(filter.filtered_tokens).not_to eq [token2]
    end

    it 'returns all tokens if there are no filters' do
      vendor1 = create(:vendor, name: 'vendor_1')
      vendor2 = create(:vendor, name: 'vendor_2')
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
      vendor1 = create(:vendor, name: 'vendor_1')
      vendor2 = create(:vendor, name: 'vendor_2')

      filter = described_class.new(filter_params: {})

      expect(filter.filters).to eq(
        [
          {
            type: :search,
            heading: 'Provider name or code',
            name: 'provider_name_or_code',
            value: nil,
          },
          {
            type: :search,
            heading: 'Token name',
            name: 'token_name',
            value: nil,
          },
          {
            type: :checkboxes,
            heading: 'Vendors',
            name: 'vendor_ids',
            options: [
              {
                value: vendor1.id,
                label: 'Vendor 1',
                checked: nil,
              },
              {
                value: vendor2.id,
                label: 'Vendor 2',
                checked: nil,
              },
            ],
          },
          {
            type: :checkboxes,
            heading: 'Activity',
            name: 'activity',
            options: [
              { value: 'recent', label: 'Used within 60 days', checked: nil },
              { value: 'not_recent', label: 'Not used for 60 days', checked: nil },
            ],
          },
        ],
      )
    end
  end

  describe '#hidden_filters' do
    it 'returns the revoked filter tab as a hidden filter when filtering revoked tokens' do
      filter = described_class.new(filter_params: { filter_tab: 'revoked' })

      expect(filter.hidden_filters).to eq(
        [{ type: :hidden, name: 'filter_tab', value: 'revoked' }],
      )
    end

    it 'does not submit the filter tab as revoked on the active tokens tab' do
      filter = described_class.new(filter_params: {})

      expect(filter.hidden_filters).to eq(
        [{ type: :hidden, name: 'filter_tab', value: nil }],
      )
    end
  end
end
