require 'rails_helper'

RSpec.describe SendChaseEmailToCandidate do
  describe '#call' do
    let(:application_choice) do
      create(:submitted_application_choice, :with_offer,
             application_form: create(:completed_application_form))
    end
    let(:application_form) { application_choice.application_form }

    before do
      described_class.call(application_form: application_form)
    end

    it 'sends a chaser email to the provider' do
      expect(application_form.chasers_sent.candidate_decision_request.count).to eq(1)
    end
  end
end
