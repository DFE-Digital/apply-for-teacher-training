require 'rails_helper'
RSpec.describe ProviderInterface::InterviewWizard do
  let(:store) { instance_double(WizardStateStores::RedisStore) }

  let(:day) { '1' }
  let(:month) { '2' }
  let(:year) { '2021' }
  let(:time) { '10am' }
  let(:application_choice) { nil }

  let(:wizard) do
    described_class.new(
      store,
      'date(3i)' => day,
      'date(2i)' => month,
      'date(1i)' => year,
      time: time,
      application_choice: application_choice,
    )
  end

  before { allow(store).to receive(:read) }

  describe '.validations' do
    context 'presence checks' do
      let(:subject) { described_class.new(store) }

      it { is_expected.to validate_presence_of(:time) }
      it { is_expected.to validate_presence_of(:date) }
      it { is_expected.to validate_presence_of(:provider_user) }
      it { is_expected.to validate_presence_of(:location) }
      it { is_expected.to validate_presence_of(:application_choice) }
    end

    describe '#date' do
      context 'when invalid' do
        let(:day) { 100 }

        it 'is invalid with the correct error' do
          expect(wizard).to be_invalid
          expect(wizard.errors[:date]).to contain_exactly('The interview date must be a real date')
        end
      end

      context 'when in the past' do
        let(:application_choice) { build_stubbed(:application_choice, reject_by_default_at: 5.days.from_now) }
        let(:year) { 2020 }

        it 'is invalid with the correct error' do
          Timecop.freeze(2021, 1, 13) do
            expect(wizard).to be_invalid
            expect(wizard.errors[:date]).to contain_exactly('Enter a date that is in the future')
          end
        end
      end

      context 'when it is after the rdb date' do
        let(:application_choice) { build_stubbed(:application_choice, reject_by_default_at: Time.zone.local(2021, 2, 14)) }
        let(:day) { 15 }

        it 'is invalid with the correct error' do
          Timecop.freeze(2021, 1, 13) do
            expect(wizard).to be_invalid
            expect(wizard.errors[:date]).to contain_exactly('The interview date must be before the application closing date')
          end
        end
      end
    end

    describe '#time_is_valid?' do
      let(:tomorrow) { 1.day.from_now }
      let(:day) { tomorrow.day }
      let(:month) { tomorrow.month }
      let(:year) { tomorrow.year }

      context 'checks if the time is in the rights format' do
        let(:invalid_times) { %w[noon 1700 12:30 12:3pm 1800pm] }
        let(:valid_times) { %w[12:30pm 2pm 1.30am 01.24AM 3\ 30am] }

        it 'returns false when the time is invalid' do
          invalid_times.each do |time|
            wizard.time = time
            expect(wizard.time_is_valid?).to eq(false)
          end
        end

        it 'returns true when the time is valid' do
          valid_times.each do |time|
            wizard.time = time
            expect(wizard.time_is_valid?).to eq(true)
          end
        end
      end
    end
  end

  describe '#date_and_time' do
    let(:time) { '4:30pm' }
    let(:day) { '20' }
    let(:month) { '2' }
    let(:year) { '2022' }

    it 'converts the :date and :time to valid datetime' do
      expect(wizard.date_and_time.hour).to equal(16)
      expect(wizard.date_and_time.min).to equal(30)
      expect(wizard.date_and_time.day).to equal(20)
      expect(wizard.date_and_time.month).to equal(2)
      expect(wizard.date_and_time.year).to equal(2022)
    end
  end
end
