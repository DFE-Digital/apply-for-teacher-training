require 'rails_helper'

RSpec.describe FindStatusChangeAudits, with_audited: true do
  let(:now) { Time.zone.local(2020, 2, 11) }

  around do |example|
    @now = Time.zone.local(2020, 2, 11)
    Timecop.freeze(@now) do
      example.run
    end
  end

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
        expect(result).to eq [
          described_class::StatusChange.new('awaiting_references', @now, candidate),
        ]
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
        expect(result).to eq [
          described_class::StatusChange.new('awaiting_references', @now, candidate),
          described_class::StatusChange.new('application_complete', @now, candidate),
          described_class::StatusChange.new('awaiting_provider_decision', @now, candidate),
          described_class::StatusChange.new('offer', @now, candidate),
          described_class::StatusChange.new('pending_conditions', @now, candidate),
        ]
      end
    end
  end
end
