require 'rails_helper'

RSpec.describe CandidateInterface::WithdrawalFeedbackForm, type: :model do
  describe 'validations' do
    let(:form) { subject }

    it { is_expected.to validate_presence_of(:feedback) }
    it { is_expected.to validate_presence_of(:consent_to_be_contacted) }

    context 'if the candidate selects they want to give feedback' do
      before { allow(form).to receive(:feedback?).and_return(true) }

      it { is_expected.to validate_presence_of(:explanation) }
    end

    context 'if the candidate selects can be contacted' do
      before { allow(form).to receive(:consent_to_be_contacted?).and_return(true) }

      it { is_expected.to validate_presence_of(:contact_details) }
    end
  end

  describe '#save' do
    it 'returns false if not valid' do
      withdrawal_feedback = described_class.new

      expect(withdrawal_feedback.save(ApplicationChoice.new)).to eq(false)
    end

    it 'updates the withdrawl feedback column if valid' do
      application_choice = create(:application_choice, status: 'withdrawn')
      withdrawal_feedback = described_class.new(
        feedback: true,
        explanation: 'I do not want to travel that far.',
        consent_to_be_contacted: true,
        contact_details: 'Anytime. 012345 678900',
      )

      expect(withdrawal_feedback.save(application_choice)).to eq(true)
      expect(application_choice.withdrawal_feedback).to eq(
        {
          CandidateInterface::WithdrawalQuestionnaire::EXPLANATION_QUESTION => true,
          'Explanation' => 'I do not want to travel that far.',
          CandidateInterface::WithdrawalQuestionnaire::CONSENT_TO_BE_CONTACTED_QUESTION => true,
          'Contact details' => 'Anytime. 012345 678900',
        },
      )
    end
  end
end
