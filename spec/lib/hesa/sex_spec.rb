require 'rails_helper'

RSpec.describe Hesa::Sex do
  describe '.all' do
    it 'returns a list of HESA sex structs' do
      sex_types = described_class.all

      expect(sex_types.size).to eq 3

      female = sex_types.find { |s| s.hesa_code == '2' }

      expect(female.hesa_code).to eq '2'
      expect(female.type).to eq 'female'
    end
  end

  describe '.find' do
    context 'given a valid type' do
      it 'returns the matching struct' do
        result = described_class.find('female')

        expect(result.type).to eq 'female'
        expect(result.hesa_code).to eq '2'
      end
    end

    context 'given an unrecognised type' do
      it 'returns nil' do
        result = described_class.find('An unrecognised type')

        expect(result).to be_nil
      end
    end
  end
end
