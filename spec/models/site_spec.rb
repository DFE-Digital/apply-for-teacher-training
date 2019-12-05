require 'rails_helper'

RSpec.describe Site, type: :model do
  subject { create(:site) }

  describe 'a valid site' do
    it { is_expected.to validate_presence_of :code }
    it { is_expected.to validate_presence_of :name }
  end

  describe '#full_address' do
    it 'concatenates the address lines and postcode' do
      site = build(
        :site,
        address_line1: 'Gorse SCITT',
        address_line2: 'C/O The Bruntcliffe Academy',
        address_line3: 'Bruntcliffe Lane',
        address_line4: 'MORLEY, lEEDS',
        postcode: 'LS27 0LZ',
      )

      expect(site.full_address).to eq('Gorse SCITT, C/O The Bruntcliffe Academy, Bruntcliffe Lane, MORLEY, lEEDS, LS27 0LZ')
    end

    it 'ignores empty address lines when concatenating' do
      site = build(
        :site,
        address_line1: '',
        address_line2: 'C/O The Bruntcliffe Academy',
        address_line3: '',
        address_line4: 'MORLEY, lEEDS',
        postcode: 'LS27 0LZ',
      )

      expect(site.full_address).to eq('C/O The Bruntcliffe Academy, MORLEY, lEEDS, LS27 0LZ')
    end
  end
end
