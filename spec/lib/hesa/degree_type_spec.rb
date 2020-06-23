require 'rails_helper'

RSpec.describe Hesa::DegreeType do
  describe '.all' do
    it 'returns a list of HESA degree type structs' do
      degree_types = described_class.all

      expect(degree_types.size).to eq 81
      ba = degree_types.find { |dt| dt.hesa_code == 51 }
      expect(ba.hesa_code).to eq 51
      expect(ba.abbreviation).to eq 'BA'
      expect(ba.name).to eq 'Bachelor of Arts'
      expect(ba.level).to eq :bachelor
    end
  end

  describe '.abbreviations_and_names' do
    it 'returns a list of concatenated abbreviations and names' do
      abbreviations_and_names = described_class.abbreviations_and_names

      expect(abbreviations_and_names.first).to eq '|BEd'
      expect(abbreviations_and_names[6]).to eq 'BA|Bachelor of Arts'
    end
  end

  describe '.find_by_name' do
    context 'given a valid name' do
      it 'returns the matching struct' do
        result = described_class.find_by_name('Bachelor of Divinity')

        expect(result.abbreviation).to eq 'BD'
        expect(result.name).to eq 'Bachelor of Divinity'
      end
    end

    context 'given an unrecognised name' do
      it 'returns nil' do
        result = described_class.find_by_name('Master of Conjuration')

        expect(result).to eq nil
      end
    end
  end
end
