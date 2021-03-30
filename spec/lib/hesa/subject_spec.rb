require 'rails_helper'

RSpec.describe Hesa::Subject do
  describe '.all' do
    it 'returns a list of HESA subject structs' do
      subjects = described_class.all

      expect(subjects.size).to eq 1092
      fashion_design = subjects.find { |s| s.hesa_code == '100055' }
      expect(fashion_design.hesa_code).to eq '100055'
      expect(fashion_design.name).to eq 'Fashion design'
    end
  end

  describe '.names' do
    it 'returns a list of all subject names' do
      names = described_class.names

      expect(names.size).to eq 1092
      expect(names.first).to eq 'Ceramics'
    end
  end

  describe '.find_by_name' do
    context 'given a valid name' do
      it 'returns the matching struct' do
        result = described_class.find_by_name('Salman Rushdie studies')

        expect(result.name).to eq 'Salman Rushdie studies'
        expect(result.hesa_code).to eq '101496'
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
