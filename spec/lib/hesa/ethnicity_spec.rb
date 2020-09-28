require 'rails_helper'

RSpec.describe Hesa::Ethnicity do
  describe '.all' do
    context 'Recruitment cycle 2019 - 2020' do
      it 'returns a list of HESA ethnicity structs' do
        cycle_year = 2020
        ethnicity_types = described_class.all(cycle_year)

        expect(ethnicity_types.size).to eq 18

        chinese = ethnicity_types.find { |e| e.hesa_code == 34 }

        expect(chinese.hesa_code).to eq 34
        expect(chinese.type).to eq HesaEthnicityTypes::CHINESE
      end
    end

    context 'Recruitment cycle 2020 - 2021' do
      it 'returns a list of HESA ethnicity structs' do
        cycle_year = 2021
        ethnicity_types = described_class.all(cycle_year)

        expect(ethnicity_types.size).to eq 16

        chinese = ethnicity_types.find { |e| e.hesa_code == 34 }

        expect(chinese.hesa_code).to eq 34
        expect(chinese.type).to eq HesaEthnicityTypes::CHINESE
      end
    end
  end

  describe '.find_by_type' do
    context 'given a valid type' do
      it 'returns the matching struct' do
        cycle_year = 2021
        result = described_class.find_by_type('Chinese', cycle_year)

        expect(result.type).to eq HesaEthnicityTypes::CHINESE
        expect(result.hesa_code).to eq 34
      end
    end

    context 'given an unrecognised type' do
      it 'returns nil' do
        result = described_class.find_by_type('Information refused', 2021)

        expect(result).to eq nil
      end
    end
  end

  describe '.convert_to_hesa_type' do
    context 'given a known ethnicity' do
      it 'returns the matching hesa type' do
        result = described_class.convert_to_hesa_type('Irish')

        expect(result).to eq HesaEthnicityTypes::WHITE
      end
    end

    context 'given an unknown ethnicity' do
      it 'returns nil' do
        result = described_class.convert_to_hesa_type('unknown ethnicity')

        expect(result).to eq nil
      end
    end
  end
end
