require 'rails_helper'

RSpec.describe DateValidator do
  let(:test_date_validator) do
    Class.new do
      include ActiveModel::Validations
      include ActiveModel::Model

      attr_accessor :date, :date_of_birth

      validates :date, date: true
      validates :date_of_birth, date: { date_of_birth: true }
    end
  end
  let(:model) { TestDateValidator.new(date: date, date_of_birth: date_of_birth) }
  let(:date_of_birth) { nil }
  let(:date) { nil }

  before do
    stub_const('TestDateValidator', test_date_validator)
  end

  context 'default date validations' do
    context 'when date is nil' do
      let(:date) { nil }

      it 'returns valid' do
        expect(model).to be_valid
      end
    end

    context 'when date information is missing' do
      let(:date) { Struct.new(:day, :month, :year).new(nil, 2, nil) }

      it 'returns :blank_date_fields error' do
        expect(model).to be_invalid
        expect(model.errors[:date]).to contain_exactly(I18n.t('errors.messages.blank_date_fields', attribute: 'date', fields: 'day and year'))
      end
    end

    context 'when date is not a Date object' do
      let(:date) { Struct.new(:day, :month, :year).new(1, 2, 3) }

      it 'returns :invalid_date error' do
        expect(model).to be_invalid
        expect(model.errors[:date]).to contain_exactly(I18n.t('errors.messages.invalid_date', article: 'a', attribute: :date))
      end
    end

    context 'when date is too far in the past' do
      let(:date) { Time.zone.today - 101.years }

      it 'returns :invalid_date error' do
        expect(model).to be_invalid
        expect(model.errors[:date]).to contain_exactly(I18n.t('errors.messages.invalid_date', article: 'a', attribute: :date))
      end
    end
  end

  context 'configurable validations' do
    context 'when future: true' do
      let(:test_date_validator) do
        Class.new do
          include ActiveModel::Validations
          include ActiveModel::Model

          attr_accessor :date

          validates :date, date: { future: true }
        end
      end
      let(:model) { TestDateValidator.new(date: date) }

      context 'when date is in the future' do
        let(:date) { Time.zone.today + 1.month }

        it 'returns :future error' do
          expect(model).to be_invalid
          expect(model.errors[:date]).to contain_exactly(I18n.t('errors.messages.future', article: 'a', attribute: :date))
        end
      end
    end

    context 'when presence: true' do
      let(:test_date_validator) do
        Class.new do
          include ActiveModel::Validations
          include ActiveModel::Model

          attr_accessor :date

          validates :date, date: { presence: true }
        end
      end
      let(:model) { TestDateValidator.new(date: date) }

      context 'when date is not set' do
        let(:date) { Struct.new(:day, :month, :year).new('', '', '') }

        it 'returns :blank error' do
          expect(model).to be_invalid
          expect(model.errors[:date]).to contain_exactly(I18n.t('errors.messages.blank_date', article: 'a', attribute: 'date'))
        end
      end
    end

    context 'when date_of_birth: true' do
      context 'when date is in the future' do
        let(:date_of_birth) { Date.new(2050, 5, 3) }

        it 'returns :dob_future error' do
          expect(model).to be_invalid
          expect(model.errors[:date_of_birth]).to contain_exactly(I18n.t('errors.messages.dob_future', article: 'a', attribute: 'date of birth'))
        end
      end

      context 'when date is below the minimum age' do
        let(:date_of_birth) { Time.zone.today - 14.years }

        it 'returns :dob_below_min_age error' do
          age_limit = Time.zone.today - 16.years

          expect(model).to be_invalid
          expect(model.errors[:date_of_birth]).to contain_exactly(
            I18n.t('errors.messages.dob_below_min_age', date: age_limit.to_s(:govuk_date), min_age: 16),
          )
        end
      end
    end

    context 'when month_and_year: true' do
      let(:test_date_validator) do
        Class.new do
          include ActiveModel::Validations
          include ActiveModel::Model

          attr_accessor :date

          validates :date, date: { month_and_year: true, presence: true }
        end
      end
      let(:model) { TestDateValidator.new(date: date) }

      context 'when presence: true' do
        let(:date) { Struct.new(:day, :month, :year).new(1, nil, nil) }

        it 'returns :blank_date error even when the day is set' do
          expect(model).to be_invalid
          expect(model.errors[:date]).to contain_exactly(I18n.t('errors.messages.blank_date', article: 'a', attribute: :date))
        end
      end

      context 'when invalid' do
        let(:date) { Date.new(1700, 5, 1) }

        it 'returns :invalid_date_month_and_year error' do
          expect(model).to be_invalid
          expect(model.errors[:date]).to contain_exactly(I18n.t('errors.messages.invalid_date_month_and_year', article: 'a', attribute: :date))
        end
      end

      context 'when presence is not set' do
        let(:test_date_validator) do
          Class.new do
            include ActiveModel::Validations
            include ActiveModel::Model

            attr_accessor :date

            validates :date, date: { month_and_year: true }
          end
        end

        it 'returns no error when the month and year are not set' do
          expect(model).to be_valid
          expect(model.errors[:date]).to be_empty
        end
      end
    end

    context 'when before: :field' do
      let(:test_date_validator) do
        Class.new do
          include ActiveModel::Validations
          include ActiveModel::Model

          attr_accessor :date, :other_date

          validates :date, date: { month_and_year: true, before: :other_date }
        end
      end

      let(:model) { TestDateValidator.new(date: date, other_date: other_date) }

      context 'when the date is after the provided field date' do
        let(:date) { Time.zone.today - 2.months }
        let(:other_date) { Time.zone.today - 5.months }

        it 'returns :before error' do
          expect(model).to be_invalid
          expect(model.errors[:date]).to contain_exactly(I18n.t('errors.messages.before', article: 'a', attribute: :date, compared_attribute: :other_date))
        end
      end
    end
  end
end
