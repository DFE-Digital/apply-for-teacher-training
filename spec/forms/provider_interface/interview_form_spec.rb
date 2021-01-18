require 'rails_helper'

RSpec.describe ProviderInterface::InterviewForm do
  let(:provider) { create(:provider, :with_user) }
  let(:course) { create(:course, provider: provider) }
  let(:application_choice) { create(:application_choice, :awaiting_provider_decision, course_option: create(:course_option, course: course)) }
  let(:provider_user) do
    provider.provider_permissions.update_all(make_decisions: true)
    provider.provider_users.first
  end

  describe 'validations' do
    it 'validates presence of :application_choice' do
      expect(described_class.new).to validate_presence_of(:application_choice)
    end

    it 'validates the date entered' do
      invalid_form = described_class.new(
        application_choice: application_choice,
        current_provider_user: provider_user,
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
          application_choice: application_choice,
          current_provider_user: provider_user,
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
          application_choice: application_choice,
          current_provider_user: provider_user,
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

    it 'validates presence of :current_provider_user' do
      expect(described_class.new).to validate_presence_of(:current_provider_user)
    end

    it 'validates presence of :location' do
      expect(described_class.new).to validate_presence_of(:location)
        .with_message('Enter an address or online meeting details')
    end
  end

  describe '#date_and_time' do
    def form_with_time(time)
      tomorrow = 1.day.from_now
      described_class.new(
        application_choice: application_choice,
        current_provider_user: provider_user,
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

  describe '#time_is_valid' do
    it 'raises an errror if input is not valid time' do
      invalid_time_form = described_class.new(
        application_choice: application_choice,
        current_provider_user: provider_user,
        year: 2022,
        month: 1,
        day: 10,
        time: '23am',
        location: 'Zoom',
      )
      expect(invalid_time_form.time_is_valid?).to equal(false)
    end
  end

  describe '#save' do
    it 'creates a new interview' do
      tomorrow = 1.day.from_now
      valid_form_object = described_class.new(
        application_choice: application_choice,
        current_provider_user: provider_user,
        year: tomorrow.year,
        month: tomorrow.month,
        day: tomorrow.day,
        time: '10am',
        location: 'Zoom',
      )

      expect(valid_form_object).to be_valid
      expect { valid_form_object.save }.to change { application_choice.interviews.count }.from(0).to(1)
    end

    it 'fails for invalid forms' do
      invalid_form_object = described_class.new(application_choice: application_choice)
      expect { invalid_form_object.save }.not_to(change { application_choice.interviews.count })
    end
  end
end
