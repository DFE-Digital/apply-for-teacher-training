require 'rails_helper'

RSpec.describe Hesa::DegreeType do
  describe '.all' do
    subject(:degree_types) { described_class.all }

    it 'does not include deprecated records' do
      expect(degree_types.map(&:name)).not_to include(
        'Bachelor of Science in Education',
        'Bachelor of Technology in Education',
        'Bachelor of Arts in Education',
      )
    end

    it 'returns a list of HESA degree type structs' do
      ba = degree_types.find { |dt| dt.hesa_code == '051' }
      expect(ba.hesa_code).to eq '051'
      expect(ba.abbreviation).to eq 'BA'
      expect(ba.name).to eq 'Bachelor of Arts'
      expect(ba.level).to eq :bachelor
    end
  end

  describe '.find_by_abbreviation_or_name' do
    context 'given a valid abbreviation' do
      it 'returns the matching struct' do
        result = described_class.find_by_abbreviation_or_name('BD')

        expect(result.abbreviation).to eq 'BD'
        expect(result.name).to eq 'Bachelor of Divinity'
      end
    end

    context 'given a valid name' do
      it 'returns the matching struct' do
        result = described_class.find_by_abbreviation_or_name('Bachelor of Divinity')

        expect(result.abbreviation).to eq 'BD'
        expect(result.name).to eq 'Bachelor of Divinity'
      end
    end

    context 'given an unrecognised name' do
      it 'returns nil' do
        result = described_class.find_by_abbreviation_or_name('Master of Conjuration')

        expect(result).to be_nil
      end
    end
  end

  describe '.where' do
    it 'returns a list of concatenated abbreviations and names' do
      degrees = described_class.where(level: :all)

      expect(degrees.map(&:name)).to include('Bachelor of Arts')
    end

    context 'when specifying undergraduate level' do
      let(:degrees) do
        described_class.where(level: :undergraduate)
      end

      it 'returns the abbreviations and names scoped to undergraduate degrees' do
        expect(
          degrees.find { |degree| degree.name.include? 'Bachelor' },
        ).not_to be_nil
        expect(
          degrees.find { |degree| degree.name.include? 'Master' },
        ).not_to be_nil

        expect(
          degrees.find { |degree| degree.name.include? 'Doctor' },
        ).to be_nil
        expect(
          degrees.find { |degree| degree.name.include? 'Degree equivalent' },
        ).to be_nil
      end
    end

    context 'when specifying degrees at different levels' do
      %i[bachelor master doctor foundation].each do |level|
        it 'returns the abbreviations and names scoped to the level' do
          degrees = described_class.where(level:)
          expect(
            degrees.find { |degree| degree.name.include? level.to_s.upcase_first.to_s },
          ).not_to be_nil
        end
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

    context 'given a valid name with case insensitive' do
      it 'returns the matching struct' do
        result = described_class.find_by_name('Bachelor of divinity')

        expect(result.abbreviation).to eq 'BD'
        expect(result.name).to eq 'Bachelor of Divinity'
      end
    end

    context 'with name blank' do
      it 'returns nil' do
        result = described_class.find_by_name(nil)

        expect(result).to be_nil
      end
    end

    context 'given an unrecognised name' do
      it 'returns nil' do
        result = described_class.find_by_name('Master of Conjuration')

        expect(result).to be_nil
      end
    end
  end

  describe '.find_by_hesa_code' do
    context 'given a valid code' do
      it 'returns the matching struct' do
        result = described_class.find_by_hesa_code('051')

        expect(result.abbreviation).to eq 'BA'
      end
    end

    context 'given a blank code' do
      it 'returns nil' do
        result = described_class.find_by_hesa_code(nil)

        expect(result).to be_nil
      end
    end

    context 'given an unrecognised code' do
      it 'returns nil' do
        result = described_class.find_by_hesa_code(99999999)

        expect(result).to be_nil
      end
    end
  end
end
