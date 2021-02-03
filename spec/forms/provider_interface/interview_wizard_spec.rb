require 'rails_helper'
RSpec.describe ProviderInterface::InterviewWizard do
  let(:store) { instance_double(WizardStateStores::RedisStore) }

  let(:day) { '1' }
  let(:month) { '2' }
  let(:year) { '2021' }
  let(:time) { '10am' }
  let(:application_choice) { nil }
  let(:provider_user) { nil }

  let(:wizard) do
    described_class.new(
      store,
      'date(3i)' => day,
      'date(2i)' => month,
      'date(1i)' => year,
      time: time,
      application_choice: application_choice,
      provider_user: provider_user,
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

    describe '#date_and_time_in_future' do
      context 'the day is on the same day and the time is in the future' do
        let(:day) { '13' }
        let(:time) { '1pm' }

        it 'returns true and adds no errors' do
          Timecop.freeze(2021, 2, 13, 12, 0, 0) do
            expect(wizard.date_and_time_in_future).to eq(true)
          end
        end
      end

      context 'the day is before today' do
        let(:day) { '12' }
        let(:time) { '9pm' }

        it 'returns false and adds a date error' do
          Timecop.freeze(2021, 2, 13, 11, 0, 0) do
            expect(wizard).to be_invalid
            expect(wizard.errors[:date]).to contain_exactly('The interview date must be in the future')
          end
        end
      end

      context 'the day is on the same day and the time is in the past' do
        let(:day) { '13' }
        let(:time) { '9am' }

        it 'returns false and adds a time error' do
          Timecop.freeze(2021, 2, 13, 11, 0, 0) do
            expect(wizard).to be_invalid
            expect(wizard.errors[:time]).to contain_exactly('The interview time must be in the future')
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

  describe '#provider_id' do
    let(:provider_user) { build_stubbed(:provider_user) }
    let(:application_choice) { build_stubbed(:application_choice) }
    let(:wizard) { described_class.new(store, provider_user: provider_user, application_choice: application_choice) }

    context 'when the application has multiple providers' do
      before do
        allow(wizard).to receive(:multiple_application_providers?).and_return(true)
      end

      it 'validates presence' do
        expect(wizard).to validate_presence_of(:provider_id)
      end
    end
  end

  describe '#provider' do
    let(:application_choice) { create(:application_choice, course_option: course_option) }
    let(:course_option) { create(:course_option, course: course) }
    let(:provider) { create(:provider) }
    let(:accredited_provider) { create(:provider) }

    context 'when the application has one provider' do
      let(:course) { create(:course, provider: provider) }
      let(:wizard) { described_class.new(store, application_choice: application_choice) }

      it 'defaults to the application provider' do
        expect(wizard.provider).to eq(application_choice.provider)
      end
    end

    context 'when the application has multiple providers and one is selected' do
      let(:course) { create(:course, provider: provider, accredited_provider: accredited_provider) }
      let(:wizard) { described_class.new(store, provider_id: accredited_provider.id, application_choice: application_choice) }

      it 'retrieves the selected provider' do
        expect(wizard.provider).to eq(accredited_provider)
      end
    end
  end

  describe '#application_providers' do
    let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option: course_option) }
    let(:course_option) { create(:course_option, course: course) }
    let(:provider) { create(:provider) }
    let(:provider_user) { create(:provider_user, :with_make_decisions, providers: [provider]) }
    let(:accredited_provider) { create(:provider) }

    context 'when the application course has both a provider and an accredited provider' do
      let(:course) { create(:course, provider: provider) }

      it 'retrieves both providers' do
        expect(wizard.application_providers).to contain_exactly(provider)
      end
    end

    context 'when the application course only has a provider set' do
      let(:course) { create(:course, provider: provider, accredited_provider: accredited_provider) }

      it 'retrieves the ratifying provider' do
        expect(wizard.application_providers).to contain_exactly(provider, accredited_provider)
      end
    end

    context 'when the application course provider and accredited provider are the same' do
      let(:course) { create(:course, provider: provider, accredited_provider: provider) }

      it 'retrieves the training provider' do
        expect(wizard.application_providers).to contain_exactly(provider)
      end
    end
  end

  describe '.from_model' do
    let(:store) { instance_double(WizardStateStores::RedisStore, read: {}) }
    let(:interview) { build_stubbed(:interview) }

    it 'initializes a wizard from the interview model' do
      wizard = described_class.from_model(store, interview, 'some_step')

      expect(wizard.application_choice).to eq(interview.application_choice)
      expect(wizard.additional_details).to eq(interview.additional_details)
      expect(wizard.date).to eq(interview.date_and_time.to_date)
      expect(wizard.send('date(3i)')).to eq(interview.date_and_time.day.to_s)
      expect(wizard.send('date(2i)')).to eq(interview.date_and_time.month.to_s)
      expect(wizard.send('date(1i)')).to eq(interview.date_and_time.year.to_s)
      expect(wizard.location).to eq(interview.location)
      expect(wizard.provider_id).to eq(interview.provider_id)
      expect(wizard.time).to eq(interview.date_and_time.strftime('%l:%M%P'))
      expect(wizard.current_step).to eq('some_step')
    end
  end
end
