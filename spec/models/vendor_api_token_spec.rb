require 'rails_helper'

RSpec.describe VendorAPIToken do
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
end
