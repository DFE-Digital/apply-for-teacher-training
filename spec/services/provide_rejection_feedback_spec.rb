require 'rails_helper'

RSpec.describe ProvideRejectionFeedback do
  let(:provide_feedback) do
    described_class.new(
      application_choice,
      helpful,
    )
  end

  describe '#call' do
    context 'when the application choice is not rejected' do
      let(:application_choice) { create(:application_choice, :awaiting_provider_decision) }
      let(:helpful) { true }

      it 'does not call the service' do
        provide_feedback.call
        expect(RejectionFeedback.find_by(application_choice: application_choice).present?).to be false
      end
    end

    context 'when the application choice is rejected' do
      let(:application_choice) { create(:application_choice, :rejected) }
      let(:helpful) { false }

      it 'creates a rejection feedback association with the application choice' do
        provide_feedback.call
        expect(RejectionFeedback.find_by(application_choice: application_choice).present?).to be true
        expect(RejectionFeedback.find_by(application_choice: application_choice).helpful).to be false
      end
    end
  end
end
