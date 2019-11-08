require 'rails_helper'

RSpec.describe CandidateInterface::InterviewPreferencesForm, type: :model do
  let(:data) do
    {
      interview_preferences: Faker::Lorem.paragraph_by_chars(number: 100),
    }
  end

  let(:form_data) do
    {
      interview_preferences: data[:interview_preferences],
    }
  end

  describe '.build_from_application' do
    it 'creates an object based on the provided ApplicationForm' do
      application_form = ApplicationForm.new(data)
      interview_preferences = CandidateInterface::InterviewPreferencesForm.build_from_application(
        application_form,
      )

      expect(interview_preferences).to have_attributes(form_data)
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      interview_preferences = CandidateInterface::InterviewPreferencesForm.new

      expect(interview_preferences.save(ApplicationForm.new)).to eq(false)
    end

    it 'updates the provided ApplicationForm if valid' do
      application_form = FactoryBot.create(:application_form)
      interview_preferences = CandidateInterface::InterviewPreferencesForm.new(form_data)

      expect(interview_preferences.save(application_form)).to eq(true)
      expect(application_form).to have_attributes(data)
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:interview_preferences) }

    valid_text = Faker::Lorem.sentence(word_count: 200)
    invalid_text = Faker::Lorem.sentence(word_count: 201)

    it { is_expected.to allow_value(valid_text).for(:interview_preferences) }
    it { is_expected.not_to allow_value(invalid_text).for(:interview_preferences) }
  end
end
