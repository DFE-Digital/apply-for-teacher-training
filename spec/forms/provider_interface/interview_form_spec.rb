require 'rails_helper'

RSpec.describe ProviderInterface::InterviewForm do
  let(:application_choice) { create(:application_choice) }
  let(:provider_user) { create(:provider_user) }

  describe 'validations' do
    it 'validates presence of :application_choice' do
      expect(described_class.new).to validate_presence_of(:application_choice)
        .with_message('Missing application_choice')
    end

    it 'validates presence of :date' do
      expect(described_class.new).to validate_presence_of(:date)
        .with_message('Enter a date')
    end

    it 'validates that :date_and_time is in the future' do
      # TODO: Write this properly
      Timecop.freeze(2021, 1, 13) do
        invalid_form = described_class.new(
          application_choice: application_choice,
          provider: provider_user.provider,
          year: 2021,
          month: 1,
          day: 10,
          time: '10am',
        )
      end
      expect(described_class.new).to validate(:date)
        .with_message('Enter a time and date in the future')
    end

    it 'validates presence and validity of :time' do
      expect(described_class.new).to validate_presence_of(:time)
        .with_message('Enter a time')
    end

    it 'validates presence of :provider' do
      expect(described_class.new).to validate_presence_of(:provider)
        .with_message('Select a provider')
    end

    it 'validates presence of :location' do
      expect(described_class.new).to validate_presence_of(:location)
        .with_message('Enter an address or online meeting details')
    end
  end

  describe '#save' do
    it 'creates a new interview' do
      valid_form_object = described_class.new(
        application_choice: application_choice,
        provider_user: provider_user,
        subject: 'A subject',
        message: 'Some text',
      )

      expect { valid_form_object.save }.to change { application_choice.interviews.count }.from(0).to(1)
    end

    it 'fails for invalid forms' do
      invalid_form_object = described_class.new(application_choice: application_choice)
      expect { invalid_form_object.save }.not_to(change { application_choice.interviews.count })
    end
  end
end
