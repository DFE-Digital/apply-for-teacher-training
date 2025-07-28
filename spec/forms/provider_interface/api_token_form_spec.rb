require 'rails_helper'

RSpec.describe ProviderInterface::APITokenForm do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:provider) }
  end

  describe 'save!' do
    before do
      allow(VendorAPIToken).to receive(:create_with_random_token!).and_call_original
    end

    context 'when form is valid' do
      it 'creates a new VendorAPIToken with a random token' do
        provider = create(:provider)
        form = described_class.new(provider:, description: 'Test API Token')

        form.save!

        expect(VendorAPIToken).to have_received(:create_with_random_token!).with(
          provider: provider,
          description: 'Test API Token',
        )
      end
    end

    context 'when form is invalid' do
      it 'does not create a new VendorAPIToken' do
        form = described_class.new(description: nil)

        form.save!

        expect(VendorAPIToken).not_to have_received(:create_with_random_token!)
      end
    end
  end
end
