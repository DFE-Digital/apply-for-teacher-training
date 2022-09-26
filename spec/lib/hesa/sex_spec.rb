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

        expect(sex_types.size).to eq 3

        female = sex_types.find { |s| s.hesa_code == '10' }

        expect(female.hesa_code).to eq '10'
        expect(female.type).to eq 'female'
      end
    end
  end

  describe '.find' do
    context 'given a valid type' do
      it 'returns the matching struct' do
        allow(RecruitmentCycle).to receive(:current_year).and_return(2022)
        result = described_class.find('female')

        expect(result.type).to eq 'female'
        expect(result.hesa_code).to eq '2'
      end
    end

    context 'when 2023' do
      it 'returns a list of HESA sex structs' do
        allow(RecruitmentCycle).to receive(:current_year).and_return(2023)
        result = described_class.find('female')

        expect(result.type).to eq 'female'
        expect(result.hesa_code).to eq '10'
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
