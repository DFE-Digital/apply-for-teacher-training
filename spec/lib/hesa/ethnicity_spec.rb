require 'rails_helper'

RSpec.describe Hesa::Ethnicity do
  describe '.all' do
    context 'Recruitment cycle 2019 - 2020' do
      it 'returns a list of HESA ethnicity structs' do
        cycle_year = 2020
        ethnicity_values = described_class.all(cycle_year)

        expect(ethnicity_values.size).to eq 19

        chinese = ethnicity_values.find { |e| e.hesa_code == '34' }

        expect(chinese.hesa_code).to eq '34'
        expect(chinese.value).to eq HesaEthnicityValues::CHINESE
      end
    end

    context 'Recruitment cycle 2020 - 2021' do
      it 'returns a list of HESA ethnicity structs' do
        cycle_year = 2021
        ethnicity_values = described_class.all(cycle_year)

        expect(ethnicity_values.size).to eq 19

        chinese = ethnicity_values.find { |e| e.hesa_code == '34' }

        expect(chinese.hesa_code).to eq '34'
        expect(chinese.value).to eq HesaEthnicityValues::CHINESE
      end
    end

    context 'Recruitment cycle 2021 - 2022' do
      it 'returns a list of HESA ethnicity structs' do
        cycle_year = 2022
        ethnicity_values = described_class.all(cycle_year)

        expect(ethnicity_values.size).to eq 19

        chinese = ethnicity_values.find { |e| e.hesa_code == '34' }

        expect(chinese.hesa_code).to eq '34'
        expect(chinese.value).to eq HesaEthnicityValues::CHINESE
      end
    end
  end

  describe '.find' do
    context 'given a valid value' do
      it 'returns the matching struct' do
        cycle_year = 2021
        result = described_class.find('Chinese', cycle_year)

        expect(result.value).to eq HesaEthnicityValues::CHINESE
        expect(result.hesa_code).to eq '34'
      end
    end

    context 'given an unrecognised value' do
      it 'returns nil' do
        result = described_class.find('Dunno', 2021)

        expect(result.value).to eq HesaEthnicityValues::NOT_KNOWN
      end
    end
  end

  describe '.convert_to_hesa_value' do
    context 'given a known ethnicity' do
      it 'returns the matching hesa value' do
        result = described_class.convert_to_hesa_value('Irish')
        roma = described_class.convert_to_hesa_value('Roma')

        expect(result).to eq HesaEthnicityValues::WHITE_IRISH
        expect(roma).to eq HesaEthnicityValues::WHITE_ROMA
      end
    end

    context 'given an unknown ethnicity' do
      it 'returns nil' do
        result = described_class.convert_to_hesa_value('unknown ethnicity')

        expect(result).to eq 'Not known'
      end
    end
  end
end
