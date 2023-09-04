require 'rails_helper'

RSpec.describe CandidateInterface::FeedbackForm, type: :model do
  describe '#save' do
    let(:application_form) { create(:application_form) }

    it 'updates the application form with the satisfaction level and feedback if the form is valid' do
      feedback_form = described_class.new(satisfaction_level: 'very_satisfied', suggestions: 'example')
      feedback_form.save(application_form)

      expect(application_form.feedback_satisfaction_level).to eq('very_satisfied')
      expect(application_form.feedback_suggestions).to eq('example')
    end

    it 'accepts submission without values present in the optional fields' do
      feedback_form = described_class.new(satisfaction_level: nil, suggestions: nil)

      expect(feedback_form.save(application_form)).to be true

      expect(application_form.feedback_satisfaction_level).to be_nil
      expect(application_form.feedback_suggestions).to be_nil
    end
  end

  describe 'validations' do
    valid_text = Faker::Lorem.sentence(word_count: 500)
    invalid_text = Faker::Lorem.sentence(word_count: 501)

    it { is_expected.to allow_value(valid_text).for(:suggestions) }
    it { is_expected.not_to allow_value(invalid_text).for(:suggestions) }
  end
end
