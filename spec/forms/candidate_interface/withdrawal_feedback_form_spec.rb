require 'rails_helper'

RSpec.describe CandidateInterface::WithdrawalFeedbackForm, type: :model do
  describe '#save' do
    let(:application_choice) { create(:application_choice) }

    it 'updates the application choice with the selected reasons if the form is valid' do
      selected_reasons = %w[reason1 reason2]
      withdrawal_feedback_form = described_class.new(selected_reasons: selected_reasons, explanation: 'example')
      withdrawal_feedback_form.save(application_choice)

      expect(application_choice.structured_withdrawal_reasons).to eq(%w[
        reason1
        reason2
      ])

      expect(application_choice.withdrawal_feedback['Is there anything else you would like to tell us']).to eq('example')
    end

    it 'accepts no selected reasons' do
      withdrawal_feedback_form = described_class.new(selected_reasons: [])

      expect(withdrawal_feedback_form.save(application_choice)).to be true
    end
  end

  describe '#selectable_reasons' do
    it 'loads the withdrawal reasons from the YAML config file' do
      allow(YAML).to receive(:load_file).with('config/withdrawal_reasons.yml').and_return(%w[reason1 reason2])

      withdrawal_feedback_form = described_class.new

      expect(withdrawal_feedback_form.selectable_reasons).to eq(%w[reason1 reason2])
    end
  end

  describe 'validations' do
    valid_text = Faker::Lorem.sentence(word_count: 500)
    invalid_text = Faker::Lorem.sentence(word_count: 501)

    it { is_expected.to allow_value(valid_text).for(:explanation) }
    it { is_expected.not_to allow_value(invalid_text).for(:explanation) }
  end
end
