require 'rails_helper'

RSpec.describe ProviderInterface::APITokenForm do
  describe 'validations' do
    it { is_expected.to validate_presence_of(:description) }
    it { is_expected.to validate_presence_of(:provider) }
    it { is_expected.to validate_presence_of(:vendor_type) }

    it 'requires a vendor name for third-party tokens' do
      form = described_class.new(description: 'Test', provider: build(:provider), vendor_type: 'third_party', vendor_name: nil)
      expect(form).not_to be_valid
      expect(form.errors[:vendor_name]).to eq(['Select a vendor'])
    end

    it 'does not require a vendor name for in-house tokens' do
      form = described_class.new(description: 'Test', provider: build(:provider), vendor_type: 'in_house')
      expect(form).to be_valid
    end
  end

  describe 'save!' do
    before do
      allow(VendorAPIToken).to receive(:create_with_random_token!).and_call_original
    end

    context 'when form is valid' do
      it 'creates a new in-house VendorAPIToken' do
        provider = create(:provider)
        form = described_class.new(provider:, description: 'Test API Token', vendor_type: 'in_house')

        form.save!

        expect(VendorAPIToken).to have_received(:create_with_random_token!).with(
          provider: provider,
          description: 'Test API Token',
          in_house_developers: true,
          vendor_id: nil,
        )
      end

      it 'creates a new third-party VendorAPIToken with the vendor' do
        vendor = create(:vendor, name: 'custom vendor')
        provider = create(:provider)
        form = described_class.new(provider:, description: 'Test API Token', vendor_type: 'third_party', vendor_name: vendor.name)

        form.save!

        expect(VendorAPIToken).to have_received(:create_with_random_token!).with(
          provider: provider,
          description: 'Test API Token',
          in_house_developers: false,
          vendor_id: vendor.id,
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
