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

  describe '.build_from_record' do
    it 'builds a form from an existing third-party token' do
      vendor = create(:vendor, name: 'tribal')
      provider = create(:provider)
      token = create(:vendor_api_token, provider:, description: 'Tribal integration', vendor:)

      form = described_class.build_from_record(token.id)

      expect(form).to have_attributes(
        description: 'Tribal integration',
        vendor_type: 'third_party',
        vendor_name: 'tribal',
        provider: provider,
      )
    end
  end

  describe 'save!' do
    before do
      allow(VendorAPIToken).to receive(:create_with_random_token!).and_call_original
    end

    context 'when form is valid' do
      it 'creates a new in-house VendorAPIToken' do
        in_house_vendor = create(:vendor)
        provider = create(:provider)
        form = described_class.new(provider:, description: 'Test API Token', vendor_type: 'in_house')

        form.save!

        expect(VendorAPIToken).to have_received(:create_with_random_token!).with(
          provider: provider,
          description: 'Test API Token',
          vendor_id: in_house_vendor.id,
        )
      end

      it 'creates a new third-party VendorAPIToken with an existing vendor' do
        vendor = create(:vendor, name: 'custom vendor')
        provider = create(:provider)
        form = described_class.new(provider:, description: 'Test API Token', vendor_type: 'third_party', vendor_name: vendor.name)

        form.save!

        expect(VendorAPIToken).to have_received(:create_with_random_token!).with(
          provider: provider,
          description: 'Test API Token',
          vendor_id: vendor.id,
        )
      end

      it 'creates a new vendor when one does not exist' do
        provider = create(:provider)
        form = described_class.new(provider:, description: 'New vendor token', vendor_type: 'third_party', vendor_name: 'Brand New Corp')

        expect { form.save! }.to change(Vendor, :count).by(1)

        new_vendor = Vendor.last
        expect(new_vendor.name).to eq('brand_new_corp')
        expect(new_vendor.status).to eq('unconfirmed')
      end

      it 'normalizes vendor name before lookup' do
        vendor = create(:vendor, name: 'tribal')
        provider = create(:provider)
        form = described_class.new(provider:, description: 'Token', vendor_type: 'third_party', vendor_name: '  Tribal  ')

        form.save!

        expect(VendorAPIToken).to have_received(:create_with_random_token!).with(
          provider: provider,
          description: 'Token',
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
