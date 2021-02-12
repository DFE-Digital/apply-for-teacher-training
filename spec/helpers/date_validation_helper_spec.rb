require 'rails_helper'

RSpec.describe DateValidationHelper, type: :helper do
  subject(:date_validation_helper) do
    Class.new do
      include ActiveModel::Validations
      include DateValidationHelper

      attr_accessor :start_date, :end_date

      def initialize(start_date, end_date)
        @start_date = start_date
        @end_date = end_date
      end
    end
  end

  let(:model) { TestDateValidationHelper.new(start_date, end_date) }

  before do
    stub_const('TestDateValidationHelper', date_validation_helper)
  end

  describe '#start_date_before_end_date' do
    context 'when end_date is invalid' do
      let(:start_date) { Struct.new(:day, :month, :year).new(1, 9, 2020) }
      let(:end_date) { Struct.new(:day, :month, :year).new(1, nil, 2020) }

      it 'does not add any errors' do
        model.start_date_before_end_date

        expect(model.errors).to be_empty
      end
    end

    context 'when start_date is invalid' do
      let(:start_date) { Struct.new(:day, :month, :year).new(1, nil, 2020) }
      let(:end_date) { Struct.new(:day, :month, :year).new(1, 10, 2020) }

      it 'does not add any errors' do
        model.start_date_before_end_date

        expect(model.errors).to be_empty
      end
    end

    context 'when no start date is set' do
      let(:start_date) { nil }
      let(:end_date) { Struct.new(:day, :month, :year).new(1, 10, 2020) }

      it 'does not add any errors' do
        model.start_date_before_end_date

        expect(model.errors).to be_empty
      end
    end

    context 'when no end_date is set' do
      let(:start_date) { Struct.new(:day, :month, :year).new(1, 12, 2020) }
      let(:end_date) { nil }

      it 'does not add any errors' do
        model.start_date_before_end_date

        expect(model.errors).to be_empty
      end
    end

    context 'when the start date is before the end date' do
      let(:start_date) { Date.new(2020, 1, 1) }
      let(:end_date) { Date.new(2020, 10, 1) }

      it 'does not add any errors' do
        model.start_date_before_end_date

        expect(model.errors).to be_empty
      end
    end

    context 'when the start date is after the end date' do
      let(:start_date) { Date.new(2022, 2, 2) }
      let(:end_date) { Date.new(2020, 10, 1) }

      it 'adds an error on :start_date' do
        model.start_date_before_end_date

        expect(model.errors).to be_added(:start_date, :before)
      end
    end
  end
end
