require 'rails_helper'

RSpec.describe CandidateInterface::FindFeedbackForm, type: :model do
  let(:form) do
    described_class.new(
      path: '/course/T92/X130',
      find_controller: 'courses',
      feedback: 'Make it better.',
      email_address: 'email@gmail.com',
      hidden_feedback_field: nil,
    )
  end

  describe 'validations' do
    it_behaves_like 'an email address valid for notify'

    it { is_expected.to validate_presence_of(:path) }
    it { is_expected.to validate_presence_of(:find_controller) }
    it { is_expected.to validate_presence_of(:feedback) }

    describe '#hidden_feedback_field_is_blank' do
      it 'validates that #hidden_feedback_field is blank' do
        invalid_form = described_class.new(
          path: '/course/T92/X130',
          find_controller: 'courses',
          feedback: 'Make it better.',
          email_address: 'email@gmail.com',
          hidden_feedback_field: 'I am a bot',
        )

        invalid_form.save

        expect(invalid_form.errors[:hidden_feedback_field]).to be_present
      end
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      expect(described_class.new.save).to be(false)
    end

    it 'creates a new FindFeedback object if valid' do
      form.save
      feedback = FindFeedback.last

      expect(FindFeedback.count).to eq 1
      expect(feedback.path).to eq form.path
      expect(feedback.find_controller).to eq form.find_controller
      expect(feedback.feedback).to eq form.feedback
      expect(feedback.email_address).to eq form.email_address
    end
  end
end
