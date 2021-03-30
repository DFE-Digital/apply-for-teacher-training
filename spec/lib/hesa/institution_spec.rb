require 'rails_helper'

RSpec.describe Hesa::Institution do
  describe '.all' do
    it 'returns a list of HESA institution structs' do
      institutions = described_class.all

      expect(institutions.size).to eq 210
      kings = institutions.find { |s| s.hesa_code == '134' }
      expect(kings.hesa_code).to eq '134'
      expect(kings.name).to eq "King's College London"
    end
  end

  describe '.names' do
    it 'returns a list of all institution names' do
      names = described_class.names

      expect(names.size).to eq 210
      expect(names.first).to eq 'The Open University'
    end
  end

  describe '.find_by_name' do
    context 'given a valid name' do
      it 'returns the matching struct' do
        result = described_class.find_by_name('Westminster College')

        expect(result.name).to eq 'Westminster College'
        expect(result.hesa_code).to eq '42'
      end
    end

    context 'given an unrecognised name' do
      it 'returns nil' do
        result = described_class.find_by_name('An unrecognised name')

        expect(result).to eq nil
      end
    end
  end
end
