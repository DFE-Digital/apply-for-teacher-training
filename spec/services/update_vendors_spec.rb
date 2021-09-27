require 'rails_helper'

RSpec.describe UpdateVendors do
  describe '#call' do
    let(:example_hash) do
      {
        'tribal' => %w[ABC1 BCA1],
        'ellucian' => %w[CAB'],
      }
    end

    before { allow(YAML).to receive(:load_file).and_return(example_hash) }

    it 'creates the vendor if it doesnt exist' do
      described_class.call
      expect(Vendor.find_by(name: 'tribal')).to be_truthy
    end

    it 'associates each known provider present in the YAML with a vendor' do
      provider = create(:provider, code: 'ABC1')
      expect { described_class.call && provider.reload }.to change(provider, :vendor_id)
    end

    it 'does not add vendor information to providers not present in the YAML' do
      provider = create(:provider, code: 'XYZ1')
      expect { described_class.call && provider.reload }.not_to change(provider, :vendor_id)
    end

    it 'removes vendor information for providers not present in the YAML' do
      provider = create(:provider, :with_vendor, code: 'XYZ1')
      expect { described_class.call && provider.reload }.to change(provider, :vendor_id).to(nil)
    end

    it 'does not make any changes if any database updates fail' do
      provider = create(:provider, :with_vendor, code: 'XYZ1')
      allow(Provider).to receive(:find_by).and_raise(ActiveRecord::ConnectionTimeoutError)
      described_class.call
    rescue ActiveRecord::ConnectionTimeoutError
      expect(provider.reload.vendor_id).not_to be_nil
    end
  end
end
