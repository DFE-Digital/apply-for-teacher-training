require 'rails_helper'

RSpec.describe CandidateInterface::GcseYearForm, type: :model do
  let(:gcse) { build_stubbed(:gcse_qualification, award_year: '2020') }

  describe 'validations' do
    it { is_expected.to validate_presence_of(:award_year) }

    it 'returns validation error if award_year is in the future' do
      Timecop.freeze(Time.zone.local(2020, 1, 1)) do
        details_form = described_class.new(award_year: '2022')

        details_form.save(gcse)

        expect(details_form.errors[:award_year]).to include('Enter a year before 2021')
      end
    end

    context 'when qualification type is GCE O LEVEL' do
      it 'returns validation error if award year is after 1988' do
        form = described_class.new(qualification_type: 'gce_o_level', award_year: '2012')
        form.validate

        expect(form.errors[:award_year]).to include('Enter a year before 1989 - GSCEs replaced O levels in 1988')
      end

      it 'returns no error if award year is valid' do
        form = described_class.new(qualification_type: 'gce_o_level')

        valid_years = (1951..1988)

        valid_years.each do |year|
          form.award_year = year
          form.validate

          expect(form.errors[:award_year]).to be_empty
        end
      end
    end
  end

  describe '#save' do
    it 'return false if not valid' do
      gcse = double
      form = described_class.new
      expect(form.save(gcse)).to eq(false)
    end

    it 'updates qualification details if valid' do
      form = described_class.new(award_year: '1990')
      gcse = create(:gcse_qualification, award_year: '1991')
      form.save(gcse)

      expect(gcse.reload.award_year).to eq('1990')
    end
  end

  describe '.build_from_qualification' do
    it 'sets grade to other and other grade to grades value' do
      gcse_details_form = described_class.build_from_qualification(gcse)

      expect(gcse_details_form.award_year).to eq '2020'
      expect(gcse_details_form.qualification_type).to eq 'gcse'
    end
  end
end
