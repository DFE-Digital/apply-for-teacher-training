require 'rails_helper'

RSpec.describe CountryFinder do
  context 'when country is in the ISO list' do
    it 'returns the expected country' do
      expect(described_class.find_name_from_iso_code('IS')).to eq 'Iceland'
    end
  end

  context 'when country is on the legacy list' do
    it 'returns the country on the legacy list' do
      expect(described_class.find_name_from_iso_code('PS')).to eq 'Occupied Palestinian Territories'
    end
  end

  context 'when country does not exist anywhere' do
    it 'returns N/A' do
      expect(described_class.find_name_from_iso_code('XXX')).to eq 'N/A'
    end
  end
end
