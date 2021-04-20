require 'rails_helper'

RSpec.describe Hesa::DegreeType do
  describe '.all' do
    it 'returns a list of HESA degree type structs' do
      degree_types = described_class.all

      expect(degree_types.size).to eq 80
      ba = degree_types.find { |dt| dt.hesa_code == '51' }
      expect(ba.hesa_code).to eq '51'
      expect(ba.abbreviation).to eq 'BA'
      expect(ba.name).to eq 'Bachelor of Arts'
      expect(ba.level).to eq :bachelor
    end
  end

  describe '.abbreviations_and_names' do
    it 'returns a list of concatenated abbreviations and names' do
      abbreviations_and_names = described_class.abbreviations_and_names

      expect(abbreviations_and_names.first).to eq 'BA|Bachelor of Arts'
      expect(abbreviations_and_names[60]).to eq 'MTheol|Master of Theology'
    end

    context 'when specifying undergraduate level' do
      let(:abbreviations_and_names) do
        described_class.abbreviations_and_names(level: :undergraduate)
      end

      it 'returns the abbreviations and names scoped to undergraduate degrees' do
        expect(
          abbreviations_and_names.find { |descriptor| descriptor.include? 'Bachelor' },
        ).not_to be_nil
        expect(
          abbreviations_and_names.find { |descriptor| descriptor.include? 'Master' },
        ).not_to be_nil

        expect(
          abbreviations_and_names.find { |descriptor| descriptor.include? 'Doctor' },
        ).to be_nil
        expect(
          abbreviations_and_names.find { |descriptor| descriptor.include? 'Degree equivalent' },
        ).to be_nil
      end
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

  describe '.find_by_hesa_code' do
    context 'given a valid code' do
      it 'returns the matching struct' do
        result = described_class.find_by_hesa_code('51')

        expect(result.abbreviation).to eq 'BA'
      end
    end

    context 'given an unrecognised code' do
      it 'returns nil' do
        result = described_class.find_by_hesa_code(99999999)

        expect(result).to eq nil
      end
    end
  end
end
