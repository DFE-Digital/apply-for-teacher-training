require 'rails_helper'

RSpec.describe UpdateVendors do
  describe '#call' do
    before { allow(YAML).to receive(:load_file).and_return({'tribal' => {'ABC1' => 'SITS', 'BCA1' => 'STANDS'}}) }

    it 'creates the vendor if it doesnt exist' do
      described_class.call
      expect(Vendor.find_by(name: 'tribal')).to be_truthy
    end

    it 'associates each provider with a vendor' do
      provider = create(:provider, code: 'ABC1')
      expect{ described_class.call && provider.reload}.to change(provider, :vendor_id)
    end
  end
end
