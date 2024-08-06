require 'rails_helper'

RSpec.describe Hesa::Sex do
  describe '.all' do
    context 'when 2022' do
      it 'returns a list of HESA sex structs' do
        sex_types = described_class.all(2022)

        expect(sex_types.size).to eq 3

        female = sex_types.find { |s| s.hesa_code == '2' }

        expect(female.hesa_code).to eq '2'
        expect(female.type).to eq 'female'
      end
    end

    context 'when 2023' do
      it 'returns a list of HESA sex structs' do
        sex_types = described_class.all(2023)

        expect(sex_types.size).to eq 5

        female = sex_types.find { |s| s.hesa_code == '10' }

        expect(female.hesa_code).to eq '10'
        expect(female.type).to eq 'female'
      end
    end

    context 'when a year without data' do
      it 'returns last one' do
        sex_types = described_class.all(2090)

        expect(sex_types.size).to eq 5

        female = sex_types.find { |s| s.hesa_code == '10' }

        expect(female.hesa_code).to eq '10'
        expect(female.type).to eq 'female'
      end
    end
  end

  describe '.find' do
    context 'given a valid type' do
      it 'returns the matching struct' do
        result = described_class.find('female', 2022)

        expect(result.type).to eq 'female'
        expect(result.hesa_code).to eq '2'
      end
    end

    context 'when 2023' do
      it 'returns a list of HESA sex structs' do
        result = described_class.find('female', 2023)

        expect(result.type).to eq 'female'
        expect(result.hesa_code).to eq '10'
      end
    end

    context 'given an unrecognised type' do
      it 'returns nil' do
        result = described_class.find('An unrecognised type', 2022)

        expect(result).to be_nil
      end
    end

    context 'when sex is prefer not to say' do
      it 'returns the matching struct' do
        result = described_class.find('Prefer not to say', 2024)

        expect(result.type).to eq 'Prefer not to say'
        expect(result.hesa_code).to eq '96'
      end
    end
  end
end
