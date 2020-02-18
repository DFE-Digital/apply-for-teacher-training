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

    it 'audits the chase emails', with_audited: true do
      expected_comment =
        "Chase emails have been sent to candidate (#{application_form.candidate.email_address})" +
        ' because the application form is close to its DBD date.'
      expect(application_form.audits.last.comment).to eq(expected_comment)
    end
  end
end
