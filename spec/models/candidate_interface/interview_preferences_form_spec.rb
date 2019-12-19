require 'rails_helper'

RSpec.describe CandidateInterface::InterviewPreferencesForm, type: :model do
  let(:data) do
    {
      interview_preferences: Faker::Lorem.paragraph_by_chars(number: 100),
    }
  end

  let(:form_data) do
    {
      any_preferences: 'yes',
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

    it 'returns no for any preferences if an empty string' do
      application_form = ApplicationForm.new(
        interview_preferences: '',
      )
      interview_preferences = CandidateInterface::InterviewPreferencesForm.build_from_application(
        application_form,
      )

      expect(interview_preferences.any_preferences).to eq('no')
    end

    it 'returns nil for any preferences if interview preferences is nil' do
      application_form = ApplicationForm.new(interview_preferences: nil)
      interview_preferences = CandidateInterface::InterviewPreferencesForm.build_from_application(
        application_form,
      )

      expect(interview_preferences.any_preferences).to eq(nil)
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

    it 'updates the provided ApplicationForm with an empty string if no is selected' do
      application_form = create(:application_form)
      interview_preferences = CandidateInterface::InterviewPreferencesForm.new(
        any_preferences: 'no',
        interview_preferences: '',
      )

      expect(interview_preferences.save(application_form)).to eq(true)
      expect(application_form).to have_attributes(
        interview_preferences: '',
      )
    end
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:any_preferences) }

    valid_text = Faker::Lorem.sentence(word_count: 200)
    invalid_text = Faker::Lorem.sentence(word_count: 201)

    it { is_expected.to allow_value(valid_text).for(:interview_preferences) }
    it { is_expected.not_to allow_value(invalid_text).for(:interview_preferences) }

    it 'validates the presence of interview preferences if chosen to add any' do
      interview_preferences = CandidateInterface::InterviewPreferencesForm.new(any_preferences: 'yes')
      error_message = t('activemodel.errors.models.candidate_interface/interview_preferences_form.attributes.interview_preferences.blank')

      interview_preferences.validate

      expect(interview_preferences.errors.full_messages_for(:interview_preferences)).to eq(
        ["Interview preferences #{error_message}"],
      )
    end
  end
end
