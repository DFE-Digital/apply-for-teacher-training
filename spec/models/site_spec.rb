require 'rails_helper'

RSpec.describe Site, type: :model do
  subject { create(:site) }

  describe 'a valid site' do
    it { is_expected.to validate_presence_of :code }
    it { is_expected.to validate_presence_of :name }
  end

  describe '#full_address' do
    let(:site) do
      build(
        :site,
        address_line1: 'Gorse SCITT',
        address_line2: 'C/O The Bruntcliffe Academy',
        address_line3: 'Bruntcliffe Lane',
        address_line4: 'MORLEY, LEEDS',
        postcode: 'LS27 0LZ',
      )
    end

    it 'concatenates the address lines and postcode' do
      expect(site.full_address).to eq('Gorse SCITT, C/O The Bruntcliffe Academy, Bruntcliffe Lane, MORLEY, LEEDS, LS27 0LZ')
    end

    it 'ignores empty address lines when concatenating' do
      site = build(
        :site,
        address_line1: '',
        address_line2: 'C/O The Bruntcliffe Academy',
        address_line3: '',
        address_line4: 'MORLEY, LEEDS',
        postcode: 'LS27 0LZ',
      )

      expect(site.full_address).to eq('C/O The Bruntcliffe Academy, MORLEY, LEEDS, LS27 0LZ')
    end

    it 'concatenates by new lines if passed in' do
      expect(site.full_address("\n")).to eq("Gorse SCITT\nC/O The Bruntcliffe Academy\nBruntcliffe Lane\nMORLEY, LEEDS\nLS27 0LZ")
    end
  end

  describe 'geocoded?' do
    it 'returns true when latitude/longitude are specified' do
      site = build(
        :site,
        latitude: '51.498024',
        longitude: '0.129919',
      )
      expect(site.geocoded?).to be true
    end

    it 'returns false when latitude is nil' do
      site = build(
        :site,
        latitude: nil,
        longitude: '0.129919',
      )
      expect(site.geocoded?).to be false
    end
  end
end
