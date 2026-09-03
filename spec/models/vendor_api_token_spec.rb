require 'rails_helper'

RSpec.describe VendorAPIToken do
  describe 'associations' do
    it { is_expected.to belong_to(:provider) }
    it { is_expected.to belong_to(:vendor).optional }
  end

  describe '.create_with_random_token!' do
    it 'generates a hashed token that can be used' do
      unhashed_token = described_class.create_with_random_token!(provider: create(:provider))

      expect(
        described_class.find_by_unhashed_token(unhashed_token),
      ).to eql(described_class.last)
    end

    it 'generates with additional attributes' do
      provider = create(:provider)
      description = 'Test API Token'
      unhashed_token = described_class.create_with_random_token!(provider: provider, description:)

      token = described_class.find_by_unhashed_token(unhashed_token)

      expect(token).to be_present
      expect(token.description).to eq('Test API Token')
      expect(token.provider).to eq(provider)
    end
  end

  describe 'discard' do
    it 'marks a token as discarded but keeps it' do
      token = create(:vendor_api_token, provider: create(:provider))

      token.discard

      expect(token).to be_discarded
      expect(described_class.with_discarded).to include(token)
      expect(described_class.discarded).to include(token)
      expect(described_class.undiscarded).not_to include(token)
    end
  end

  describe '#status' do
    it 'returns active for an undiscarded token' do
      token = create(:vendor_api_token, provider: create(:provider))

      expect(token.status).to eq 'active'
    end

    it 'returns revoked for a discarded token' do
      token = create(:vendor_api_token, provider: create(:provider))
      token.discard

      expect(token.status).to eq 'revoked'
    end
  end

  describe '#vendor_name' do
    it 'returns the humanized vendor name for a third-party token' do
      vendor = create(:vendor, name: 'tribal')
      token = create(:vendor_api_token, provider: create(:provider), vendor:)

      expect(token.vendor_name).to eq 'Tribal'
    end

    it 'returns In-house developers for an in-house token' do
      token = create(:vendor_api_token, provider: create(:provider), in_house_developers: true)

      expect(token.vendor_name).to eq 'In-house developers'
    end
  end
end
