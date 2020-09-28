require 'rails_helper'

RSpec.describe Hesa::Disability do
  describe '.all' do
    it 'returns a list of HESA disability structs' do
      disability_types = described_class.all

      expect(disability_types.size).to eq 10

      deaf = disability_types.find { |e| e.hesa_code == '57' }

      expect(deaf.hesa_code).to eq '57'
      expect(deaf.type).to eq HesaDisabilityTypes::DEAF
    end
  end

  describe '.find_by_type' do
    context 'given a valid type' do
      it 'returns the matching struct' do
        result = described_class.find_by_type('Deaf or a serious hearing impairment')

        expect(result.type).to eq HesaDisabilityTypes::DEAF
        expect(result.hesa_code).to eq '57'
      end
    end

    context 'given an unrecognised type' do
      it 'returns nil' do
        result = described_class.find_by_type('Unrecognised disability')

        expect(result).to eq nil
      end
    end
  end

  describe '.convert_to_hesa_type' do
    context 'given a known disability' do
      it 'returns the matching hesa type' do
        result = described_class.convert_to_hesa_type('Social or communication impairment')

        expect(result).to eq HesaDisabilityTypes::SOCIAL_OR_COMMUNICATION
      end
    end

    context 'given an unknown disability' do
      it 'returns nil' do
        result = described_class.convert_to_hesa_type('unrecognised disability')

        expect(result).to eq nil
      end
    end
  end
end
