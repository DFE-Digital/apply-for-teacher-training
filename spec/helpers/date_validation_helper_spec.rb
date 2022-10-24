require 'rails_helper'

RSpec.describe DateValidationHelper do
  shared_examples_for 'a date that is invalid' do
    it 'returns a struct' do
      expect(subject).not_to be_a(Date)
      expect(subject).to have_attributes(year:, month: expected_month, day: 1)
    end
  end

  shared_examples_for 'a date that is valid' do
    it 'returns a valid date' do
      expect(subject).to be_a(Date)
      expect(subject).to have_attributes(year: year.to_i, month: expected_month.to_i, day: 1)
    end
  end

  describe '#valid_or_invalid_date' do
    let(:year) { '2018' }
    let(:month) { '12' }
    let(:expected_month) { month }

    subject(:date) { valid_or_invalid_date(year, month) }

    it_behaves_like 'a date that is valid'

    context 'when the month is blank' do
      let(:month) { '' }

      it_behaves_like 'a date that is invalid'
    end

    context 'when the month is a large number' do
      let(:month) { '123456789123456789123456789' }

      it_behaves_like 'a date that is invalid'
    end

    context 'when the month is a negative number' do
      let(:month) { '-5' }
      let(:expected_month) { '8' }

      it_behaves_like 'a date that is valid'
    end

    context 'when the month is a large negative number' do
      let(:month) { '-123456789123456789123456789' }

      it_behaves_like 'a date that is invalid'
    end

    context 'when the year is blank' do
      let(:year) { '' }

      it_behaves_like 'a date that is invalid'
    end

    context 'when the year is a negative number' do
      let(:year) { '-2018' }

      it_behaves_like 'a date that is valid'
    end

    context 'when the year is a large number' do
      let(:year) { '123456789123456789123456789' }

      it_behaves_like 'a date that is valid'
    end

    context 'when the year includes non-numerics' do
      let(:month) { 'last year' }

      it_behaves_like 'a date that is invalid'
    end

    context 'when the month is written in words' do
      let(:month) { 'december' }

      it 'returns a valid date' do
        expect(date).to be_a(Date)
        expect(date).to have_attributes(year: year.to_i, month: 12, day: 1)
      end
    end

    context 'when the short hand month is written in words' do
      let(:month) { 'jun' }

      it 'returns a valid date' do
        expect(date).to be_a(Date)
        expect(date).to have_attributes(year: year.to_i, month: 6, day: 1)
      end
    end

    context 'when the short hand month is written in caps' do
      let(:month) { 'FEB' }

      it 'returns a valid date' do
        expect(date).to be_a(Date)
        expect(date).to have_attributes(year: year.to_i, month: 2, day: 1)
      end
    end

    context 'when the month is not a human readable month' do
      let(:month) { 'foo' }

      it_behaves_like 'a date that is invalid'
    end
  end
end
