require 'rails_helper'
RSpec.describe ProviderInterface::InterviewWizard do
  let(:store) { instance_double(WizardStateStores::RedisStore) }

  let(:day) { '1' }
  let(:month) { '2' }
  let(:year) { '2021' }
  let(:time) { '10am' }
  let(:application_choice) { build_stubbed(:application_choice, reject_by_default_at: Time.zone.local(2021, 2, 14)) }
  let(:provider_user) { build_stubbed(:provider_user) }
  let(:location) { 'Zoom' }

  let(:wizard) do
    described_class.new(
      store,
      {
        'date(3i)' => day,
        'date(2i)' => month,
        'date(1i)' => year,
        time:,
        location:,
        application_choice:,
        provider_user:,
      },
    )
  end

  before { allow(store).to receive(:read) }

  describe '.validations' do
    context 'presence checks' do
      subject { described_class.new(store) }

      it { is_expected.to validate_presence_of(:time) }
      it { is_expected.to validate_presence_of(:provider_user) }
      it { is_expected.to validate_presence_of(:location) }
      it { is_expected.to validate_presence_of(:application_choice) }
    end

    context 'word count checks' do
      subject { described_class.new(store) }

      valid_text = Faker::Lorem.sentence(word_count: 2000)
      invalid_text = Faker::Lorem.sentence(word_count: 2001)

      it { is_expected.to allow_value(valid_text).for(:location) }
      it { is_expected.not_to allow_value(invalid_text).for(:location) }
      it { is_expected.to allow_value(valid_text).for(:additional_details) }
      it { is_expected.not_to allow_value(invalid_text).for(:additional_details) }
    end

    describe '#date' do
      context 'when blank' do
        let(:day) { '' }
        let(:month) { '' }
        let(:year) { '' }

        it 'is invalid with the correct error' do
          expect(wizard).not_to be_valid
          expect(wizard.errors[:date]).to contain_exactly('Enter interview date')
        end
      end

      context 'when invalid' do
        let(:day) { 100 }

        it 'is invalid with the correct error' do
          expect(wizard).not_to be_valid
          expect(wizard.errors[:date]).to contain_exactly('Interview date must be a real date')
        end
      end

      context 'when it is in the past' do
        let(:application_choice) { build_stubbed(:application_choice, reject_by_default_at: Time.zone.local(2021, 2, 14)) }
        let(:day) { 12 }

        it 'is invalid with the correct error' do
          travel_temporarily_to(2021, 2, 13) do
            expect(wizard).not_to be_valid
            expect(wizard.errors[:date]).to contain_exactly('Interview date must be today or in the future')
          end
        end
      end
    end

    describe '#time' do
      let(:time) { '' }

      it 'is invalid with the correct error when blank' do
        expect(wizard).not_to be_valid
        expect(wizard.errors[:time]).to contain_exactly('Enter interview time')
      end
    end

    describe '#time_is_valid' do
      let(:day) { '2' }
      let(:month) { '2' }
      let(:year) { '2021' }

      before do
        TestSuiteTimeMachine.travel_permanently_to(Time.zone.local(2021, 2, 1))
      end

      context 'checks if the time is in the correct format' do
        let(:invalid_times) do
          ['00am', '0am', '17:15am', '1715am', '20:45pm', '900a m', 'noon', '12:3pm', '1800pm', '30am', '14pm', '6767']
        end
        let(:valid_times) do
          ['05:15', '16:15', '0755', '1535', '09.43', '17.26', '08 26', '18 24', '8:am', '3:pm', '615am', '745.pm',
           '900a.m.', '1000a.m', '1200 am', '6 30am', '7 30 am', '0515pm', '05:15am', '01.15am', '5:00am', '3.', '13',
           '12:30pm', '2pm', '1.30am', '01.24AM', '09am', '9:00am', '9 00am', '9am', '9:30am', '9 30am', '9.30am',
           '00', '0', '06']
        end

        it 'the wizard is invalid and contains the right error when time is invalid' do
          invalid_times.each do |time|
            wizard.time = time
            expect(wizard).not_to be_valid
            expect(wizard.errors[:time]).to contain_exactly('Enter an interview time in the correct format')
          end
        end

        it 'the wizard is valid when time is valid' do
          valid_times.each do |time|
            wizard.time = time
            expect(wizard).to be_valid, "Time invalid #{time}, #{day} #{month} #{year} #{Time.zone.now}"
            expect(wizard.errors[:time]).to be_empty
          end
        end
      end
    end

    describe '#date_and_time_in_future' do
      context 'the day is on the same day and the time is in the future' do
        let(:day) { '13' }
        let(:time) { '1pm' }

        it 'returns true and adds no errors' do
          travel_temporarily_to(2021, 2, 13, 12, 0, 0) do
            expect(wizard).to be_valid
          end
        end
      end

      context 'the day is before today' do
        let(:day) { '12' }
        let(:time) { '9pm' }

        it 'returns false and adds a date error' do
          travel_temporarily_to(2021, 2, 13, 11, 0, 0) do
            expect(wizard).not_to be_valid
            expect(wizard.errors[:date]).to contain_exactly('Interview date must be today or in the future')
          end
        end
      end

      context 'the day is on the same day and the time is in the past' do
        let(:day) { '13' }
        let(:time) { '9am' }

        it 'returns false and adds a time error' do
          travel_temporarily_to(2021, 2, 13, 11, 0, 0) do
            expect(wizard).not_to be_valid
            expect(wizard.errors[:time]).to contain_exactly('Interview time must be in the future')
          end
        end
      end
    end
  end

  describe '#date_and_time' do
    let(:day) { '20' }
    let(:month) { '2' }
    let(:year) { '2022' }
    let(:valid_times) do
      [
        { input: '12:30pm', expected_hour: 12, expected_minute: 30 },
        { input: '2pm', expected_hour: 14, expected_minute: 0 },
        { input: '2:30pm', expected_hour: 14, expected_minute: 30 },
        { input: '2 30pm', expected_hour: 14, expected_minute: 30 },
        { input: '2.30pm', expected_hour: 14, expected_minute: 30 },
        { input: '1.30am', expected_hour: 1, expected_minute: 30 },
        { input: '01.24AM', expected_hour: 1, expected_minute: 24 },
        { input: '09am', expected_hour: 9, expected_minute: 0 },
        { input: '9:00am', expected_hour: 9, expected_minute: 0 },
        { input: '9 00am', expected_hour: 9, expected_minute: 0 },
        { input: '9am', expected_hour: 9, expected_minute: 0 },
        { input: '9:30am', expected_hour: 9, expected_minute: 30 },
        { input: '9 30am', expected_hour: 9, expected_minute: 30 },
        { input: '9.30am', expected_hour: 9, expected_minute: 30 },
      ]
    end

    context 'when the time format is valid' do
      it 'converts the :date and :time to valid datetime' do
        travel_temporarily_to(Date.new(2022, 2, 13)) do
          valid_times.each do |time|
            wizard.time = time[:input]
            expect(wizard.date_and_time.hour).to equal(time[:expected_hour])
            expect(wizard.date_and_time.min).to equal(time[:expected_minute])
            expect(wizard.date_and_time.day).to equal(20)
            expect(wizard.date_and_time.month).to equal(2)
            expect(wizard.date_and_time.year).to equal(2022)
          end
        end
      end
    end
  end

  describe '#provider_id' do
    let(:wizard) { described_class.new(store, { provider_user: provider_user, application_choice: application_choice }) }

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
    let(:application_choice) { create(:application_choice, course_option:) }
    let(:course_option) { create(:course_option, course:) }
    let(:provider) { create(:provider) }
    let(:accredited_provider) { create(:provider) }

    context 'when the application has one provider' do
      let(:course) { create(:course, provider: provider) }
      let(:wizard) { described_class.new(store, { application_choice: application_choice }) }

      it 'defaults to the application provider' do
        expect(wizard.provider).to eq(application_choice.provider)
      end
    end

    context 'when the application has multiple providers and one is selected' do
      let(:course) { create(:course, provider: provider, accredited_provider: accredited_provider) }
      let(:wizard) { described_class.new(store, { provider_id: accredited_provider.id, application_choice: application_choice }) }

      it 'retrieves the selected provider' do
        expect(wizard.provider).to eq(accredited_provider)
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
      expect(wizard.time).to eq(interview.date_and_time.strftime('%-l:%M%P'))
      expect(wizard.current_step).to eq('some_step')
    end
  end
end
