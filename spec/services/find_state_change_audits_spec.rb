require 'rails_helper'

RSpec.describe FindStateChangeAudits, with_audited: true do
  context 'for an unsubmitted application' do
    it 'returns an empty array' do
      candidate = create :candidate, email_address: 'alice@example.com'
      Audited.audit_class.as_user(candidate) do
        application_choice = create :application_choice, status: :unsubmitted
        result = described_class.new(
          application_choice: application_choice,
        ).call
        expect(result).to eq []
      end
    end
  end

  context 'for a submitted application' do
    it 'returns a single event' do
      candidate = create :candidate, email_address: 'alice@example.com'
      Audited.audit_class.as_user(candidate) do
        application_choice = create :application_choice, status: :unsubmitted
        SubmitApplication.new(application_choice.application_form).call
        result = described_class.new(
          application_choice: application_choice,
        ).call
        expect(result).to eq [application_choice.audits.last]
      end
    end
  end
end
