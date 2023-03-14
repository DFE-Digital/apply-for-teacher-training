require 'rails_helper'

RSpec.describe CandidateInterface::WithdrawalFeedbackForm, type: :model do
  describe 'validations' do
    it 'requires at least one reason to be selected' do
      withdrawal_feedback_form = described_class.new(selected_reasons: [])
      expect(withdrawal_feedback_form).not_to be_valid
      expect(withdrawal_feedback_form.errors[:selected_reasons]).to include('Select at least one reason')
    end
  end

  describe '#save' do
    let(:application_choice) { create(:application_choice) }

    it 'updates the application choice with the selected reasons if the form is valid' do
      selected_reasons = %w[reason1 reason2]
      withdrawal_feedback_form = described_class.new(selected_reasons: selected_reasons)
      withdrawal_feedback_form.save(application_choice)

      expect(application_choice.structured_withdrawal_reasons).to eq(%w[
        reason1
        reason2
      ])
    end

    it 'returns false and does not update the application choice if the form is invalid' do
      withdrawal_feedback_form = described_class.new(selected_reasons: [])

      expect(withdrawal_feedback_form.save(application_choice)).to be(false)
    end
  end

  describe '#selectable_reasons' do
    it 'loads the withdrawal reasons from the YAML config file' do
      allow(YAML).to receive(:load_file).with('config/withdrawal_reasons.yml').and_return(%w[reason1 reason2])

      withdrawal_feedback_form = described_class.new

      expect(withdrawal_feedback_form.selectable_reasons).to eq(%w[reason1 reason2])
    end
  end
end
