require 'rails_helper'
RSpec.describe ProviderInterface::InterviewWizard do
  let(:application_choice) { build_stubbed(:application_choice, :awaiting_provider_decision, course_option: build_stubbed(:course_option, course: course)) }
  let(:course) { build_stubbed(:course, provider: provider_user.providers.first) }
  let(:provider_user) { build_stubbed(:provider_user, :with_provider, :with_make_decisions) }
  let(:store) { instance_double(WizardStateStores::RedisStore) }

  before { allow(store).to receive(:read) }

  describe 'validations' do
    it 'validates presence of :application_choice' do
      expect(described_class.new(store)).to validate_presence_of(:application_choice)
    end

    it 'validates the date entered' do
      invalid_form = described_class.new(
        store,
        application_choice: application_choice,
        provider_user: provider_user,
        year: 2020,
        month: 1,
        day: 100,
        time: '10am',
        location: 'Zoom',
      )
      expect(invalid_form).to be_invalid
      expect(invalid_form.errors[:date]).to include 'Enter a valid date'
    end

    it 'validates that :date_and_time is in the future' do
      Timecop.freeze(2021, 1, 13) do
        invalid_form = described_class.new(
          store,
          application_choice: application_choice,
          provider_user: provider_user,
          year: 2021,
          month: 1,
          day: 10,
          time: '10am',
          location: 'Zoom',
        )
        expect(invalid_form).to be_invalid
        expect(invalid_form.errors[:date]).to include 'Enter a date in the future'
      end
    end

    describe 'validates :time is in the right format' do
      def form_with_time(time)
        tomorrow = 1.day.from_now
        described_class.new(
          store,
          application_choice: application_choice,
          provider_user: provider_user,
          year: tomorrow.year,
          month: tomorrow.month,
          day: tomorrow.day,
          time: time,
          location: 'Zoom',
        )
      end

      invalid_times = %w[noon 1700 12:30 12:3pm 1800pm]
      invalid_times.each do |time|
        it "#{time} is invalid" do
          form = form_with_time(time)
          expect(form).to be_invalid
          expect(form.errors[:time]).to include 'Enter a valid time'
        end
      end

      valid_times = %w[12:30pm 2pm 1.30am 01.24AM 3\ 30am]
      valid_times.each do |time|
        it "#{time} is valid" do
          expect(form_with_time(time)).to be_valid
        end
      end
    end

    it 'validates presence of :provider_user' do
      expect(described_class.new(store)).to validate_presence_of(:provider_user)
    end

    it 'validates presence of :location' do
      expect(described_class.new(store)).to validate_presence_of(:location)
    end
  end

  describe '#date_and_time' do
    def form_with_time(time)
      tomorrow = 1.day.from_now
      described_class.new(
        store,
        application_choice: application_choice,
        provider_user: provider_user,
        year: tomorrow.year,
        month: tomorrow.month,
        day: tomorrow.day,
        time: time,
        location: 'Zoom',
      )
    end

    time_conversions = {
      '12:30pm' => [12, 30],
      '2pm' => [14, 0],
      '5:30pM' => [17, 30],
      '1:30am' => [1, 30],
      '01:24am' => [1, 24],
      '3:30pm' => [15, 30],
      '2 24Am' => [2, 24],
      '5.35Pm' => [17, 35],
    }
    time_conversions.each do |input_time, (expected_hour, expected_minute)|
      it "#{input_time} parses correctly" do
        expect(form_with_time(input_time).date_and_time.hour).to equal(expected_hour)
        expect(form_with_time(input_time).date_and_time.min).to equal(expected_minute)
      end
    end
  end
end
