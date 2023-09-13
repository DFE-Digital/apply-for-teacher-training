require 'rails_helper'

RSpec.describe SendChaseEmailToCandidate do
  describe '#call' do
    let(:application_choice) do
      create(:application_choice, :awaiting_provider_decision, :offered,
             application_form: create(:completed_application_form))
    end
    let(:application_form) { application_choice.application_form }

    before do
      described_class.call(application_form:)
    end

    context 'with continuous applications feature flag inactive', continuous_applications: false do
      it 'sends a chaser email to the provider' do
        expect(application_form.chasers_sent.candidate_decision_request.count).to eq(1)
      end
    end

    context 'with continuous applications feature flag active', :continuous_applications do
      it 'sends a chaser email to the provider' do
        expect(application_form.chasers_sent.candidate_decision_request.count).to eq(0)
      end
    end
  end
end
