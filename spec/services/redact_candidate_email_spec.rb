require 'rails_helper'

RSpec.describe RedactCandidateEmail, :with_audited do
  describe '#call' do
    let(:candidate) { create(:candidate) }
    let(:custom_audit_comment) { 'Candidate requested email removal.' }
    let(:expected_comment) do
      <<~COMMENT
        User email replaced following request to stop automatic email reminders and communications.
        User advised that this will prevent access to their account and may also prevent
        communications from providers they have applied to. Reversion to original email address
        permitted if requested to grant access to account. Extra information: #{custom_audit_comment}
      COMMENT
    end

    subject(:service) { described_class.new(candidate, audit_comment: custom_audit_comment) }

    it 'updates the email_address to the redacted format' do
      service.call

      expect(candidate.reload.email_address).to eq("redacted-email-address-#{candidate.id}@example.com")
    end

    it 'adds the correct audit comment' do
      service.call

      expect(candidate.reload.audits.last.comment).to eq(expected_comment)
    end

    it 'raises an error if the candidate update fails' do
      allow(candidate).to receive(:update!).and_raise(ActiveRecord::RecordInvalid)

      expect { service.call }.to raise_error(ActiveRecord::RecordInvalid)
    end
  end
end
