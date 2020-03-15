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
        ApplicationStateChange.new(application_choice).submit!
        result = described_class.new(
          application_choice: application_choice,
        ).call
        expect(result).to eq [application_choice.audits.last]
      end
    end
  end

  context 'for an accepted application' do
    it 'returns 5 status change events' do
      candidate = create :candidate, email_address: 'alice@example.com'
      Audited.audit_class.as_user(candidate) do
        application_choice = create :application_choice, status: :unsubmitted
        ApplicationStateChange.new(application_choice).submit!
        ApplicationStateChange.new(application_choice).references_complete!
        ApplicationStateChange.new(application_choice).send_to_provider!
        ApplicationStateChange.new(application_choice).make_offer!
        ApplicationStateChange.new(application_choice).accept!
        result = described_class.new(
          application_choice: application_choice,
        ).call
        expect(result.count).to be 5
      end
    end
  end
end
