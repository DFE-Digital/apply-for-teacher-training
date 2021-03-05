require 'rails_helper'

RSpec.describe YearValidator do
  let(:test_date_validator) do
    Class.new do
      include ActiveModel::Validations
      include ActiveModel::Model

      attr_accessor :year

      validates :year, year: true
    end
  end
  let(:model) { TestYearValidator.new(year: year) }
  let(:year) { nil }

  before do
    stub_const('TestYearValidator', test_date_validator)
  end

  describe 'is valid' do
    context 'when year is nil' do
      let(:date) { nil }

      it 'returns no error' do
        expect(model).to be_valid
      end
    end

    context 'when year is in the correct format' do
      let(:year) { Time.zone.now.year }

      it 'returns no error' do
        expect(model).to be_valid
      end
    end
  end

  context 'when year is invalid' do
    context 'when year is not a number' do
      let(:year) { 'A950' }

      it 'returns :invalid_year error' do
        expect(model).to be_invalid
        expect(model.errors[:year]).to contain_exactly(I18n.t('errors.messages.invalid_year', attribute: 'year'))
      end
    end

    context 'when year is outside the acceptable year range' do
      let(:year) { '1850' }

      it 'returns :invalid_year error' do
        expect(model).to be_invalid
        expect(model.errors[:year]).to contain_exactly(I18n.t('errors.messages.invalid_year', attribute: 'year'))
      end
    end
  end

  context 'when future: true' do
    let(:test_date_validator) do
      Class.new do
        include ActiveModel::Validations
        include ActiveModel::Model

        attr_accessor :year

        validates :year, year: { future: true }
      end
    end

    context 'when the year is in the future' do
      let(:year) { '2050' }

      it 'returns :future error' do
        expect(model).to be_invalid
        expect(model.errors[:year]).to contain_exactly(I18n.t('errors.messages.future', article: 'a', attribute: 'year'))
      end
    end
  end
end
