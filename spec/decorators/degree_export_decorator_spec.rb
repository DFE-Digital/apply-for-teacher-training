require 'rails_helper'

RSpec.describe DegreeExportDecorator do
  let(:degree) { build(:degree_qualification) }

  subject(:decorator) { described_class.new(degree) }

  describe '#qualification_type_hesa_code' do
    context 'when degree is present' do
      before { allow(degree).to receive(:qualification_type_hesa_code).and_return('ABC') }

      it 'returns the qualification type HESA code padded to 3 digits' do
        expect(decorator.qualification_type_hesa_code).to eq('ABC')
      end
    end

    context 'when degree is nil' do
      let(:degree) { nil }

      it 'returns "no degree"' do
        expect(decorator.qualification_type_hesa_code).to eq('no degree')
      end
    end
  end

  describe '#decorator_hesa_code' do
    context 'when degree is present' do
      before { allow(degree).to receive(:subject_hesa_code).and_return('XYZ') }

      it 'returns the decorator HESA code padded to 4 digits' do
        expect(decorator.subject_hesa_code).to eq('0XYZ')
      end
    end

    context 'when degree is nil' do
      let(:degree) { nil }

      it 'returns "no degree"' do
        expect(decorator.subject_hesa_code).to eq('no degree')
      end
    end
  end

  describe '#grade_hesa_code' do
    context 'when degree is present' do
      before { allow(degree).to receive(:grade_hesa_code).and_return('DEF') }

      it 'returns the grade HESA code padded to 2 digits' do
        expect(decorator.grade_hesa_code).to eq('DEF')
      end
    end

    context 'when degree is nil' do
      let(:degree) { nil }

      it 'returns "no degree"' do
        expect(decorator.grade_hesa_code).to eq('no degree')
      end
    end
  end

  describe '#institution_country' do
    context 'when degree is present' do
      before { allow(degree).to receive(:institution_country).and_return('UK') }

      it 'returns the institution country padded to 2 digits' do
        expect(decorator.institution_country).to eq('UK')
      end
    end

    context 'when degree is nil' do
      let(:degree) { nil }

      it 'returns "no degree"' do
        expect(decorator.institution_country).to eq('no degree')
      end
    end
  end

  describe '#institution_hesa_code' do
    context 'when degree is present' do
      before { allow(degree).to receive(:institution_hesa_code).and_return('1234') }

      it 'returns the institution HESA code padded to 4 digits' do
        expect(decorator.institution_hesa_code).to eq('1234')
      end
    end

    context 'when degree is nil' do
      let(:degree) { nil }

      it 'returns "no degree"' do
        expect(decorator.institution_hesa_code).to eq('no degree')
      end
    end
  end

  describe '#start_year' do
    context 'when degree is present' do
      before { allow(degree).to receive(:start_year).and_return(2020) }

      it 'returns the start year in ISO8601 format' do
        expect(decorator.start_year).to eq('2020-01-01')
      end
    end

    context 'when start year is nil' do
      before { allow(degree).to receive(:start_year).and_return(nil) }

      it 'returns nil' do
        expect(decorator.start_year).to be_nil
      end
    end

    context 'when degree is nil' do
      let(:degree) { nil }

      it 'returns "no degree"' do
        expect(decorator.start_year).to eq('no degree')
      end
    end
  end

  describe '#award_year' do
    context 'when degree is present' do
      before { allow(degree).to receive(:award_year).and_return(2022) }

      it 'returns the award year in ISO8601 format' do
        expect(decorator.award_year).to eq('2022-01-01')
      end
    end

    context 'when award year is nil' do
      before { allow(degree).to receive(:award_year).and_return(nil) }

      it 'returns nil' do
        expect(decorator.award_year).to be_nil
      end
    end

    context 'when degree is nil' do
      let(:degree) { nil }

      it 'returns "no degree"' do
        expect(decorator.award_year).to eq('no degree')
      end
    end
  end
end
