require 'rails_helper'

RSpec.describe Hesa::Institution do
  describe '.all' do
    it 'returns a list of HESA institution structs' do
      institutions = described_class.all

      institution = institutions.find { |s| s.hesa_code == '0003' }
      expect(institution.hesa_code).to eq '0003'
      expect(institution.name).to eq 'Royal College of Art'
    end
  end

  describe '.names' do
    it 'returns a list of all institution names' do
      names = described_class.names

      expect(names.first).to eq 'The Open University'
    end
  end

  describe '.find_by_name' do
    let(:result) { described_class.find_by_name(name) }

    context 'given a valid name' do
      let(:name) { 'York St John University' }

      it 'returns the matching struct' do
        expect(result.name).to eq name
        expect(result.hesa_code).to eq '0013'
      end
    end

    context 'given a match synonym' do
      let(:name) { 'Edge Hill College' }

      it 'returns the matching struct' do
        expect(result.name).to eq 'Edge Hill University'
        expect(result.hesa_code).to eq '0016'
      end
    end

    context 'given an unrecognised name' do
      let(:name) { 'An unrecognised name' }

      it 'returns nil' do
        expect(result).to be_nil
      end
    end
  end
end
