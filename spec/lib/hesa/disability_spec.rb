require 'rails_helper'

RSpec.describe Hesa::Disability do
  describe '.all' do
    context 'Recruitment cycle 2021 - 2022' do
      it 'returns a list of HESA disability structs' do
        cycle_year = 2022
        disability_values = described_class.all(cycle_year)

        expect(disability_values.size).to eq 10

        deaf = disability_values.find { |disability_value| disability_value.hesa_code == '57' }

        expect(deaf.hesa_code).to eq '57'
        expect(deaf.value).to eq HesaDisabilityValues::DEAF
      end
    end

    context 'Recruitment cycle 2022 - 2023' do
      it 'returns a list of HESA disability structs' do
        cycle_year = 2023
        disability_values = described_class.all(cycle_year)

        expect(disability_values.size).to eq 12

        deaf = disability_values.find { |e| e.hesa_code == '57' }

        expect(deaf.hesa_code).to eq '57'
        expect(deaf.value).to eq HesaDisabilityValues::DEAF
      end
    end
  end

  describe '.find' do
    context 'given a valid value' do
      it 'returns the matching struct' do
        cycle_year = 2023
        result = described_class.find('Deaf', cycle_year)

        expect(result.value).to eq HesaDisabilityValues::DEAF
        expect(result.hesa_code).to eq '57'
      end
    end

    context 'given an unrecognised value' do
      it 'returns nil' do
        cycle_year = 2023
        result = described_class.find('Unrecognised disability', cycle_year)

        expect(result.value).to eq HesaDisabilityValues::OTHER
        expect(result.hesa_code).to eq '96'
      end
    end
  end

  describe '.convert_to_hesa_value' do
    context 'given a known disability' do
      it 'returns the matching hesa value' do
        result = described_class.convert_to_hesa_value('Social or communication impairment')

        expect(result).to eq HesaDisabilityValues::SOCIAL_OR_COMMUNICATION
      end
    end

    context 'given an unknown disability' do
      it 'returns nil' do
        result = described_class.convert_to_hesa_value('unrecognised disability')

        expect(result).to eq 'A disability, impairment or medical condition that is not listed above'
      end
    end
  end
end
