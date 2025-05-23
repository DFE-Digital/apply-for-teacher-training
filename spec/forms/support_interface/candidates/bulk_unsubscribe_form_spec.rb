require 'rails_helper'

RSpec.describe SupportInterface::Candidates::BulkUnsubscribeForm, type: :model do
  let(:audit_user) { create(:support_user) }
  let(:audit_comment) { 'audit_comment' }

  describe '#save' do
    it 'returns false if email is blank' do
      form = described_class.new(
        audit_user:,
        audit_comment: 'comment',
        email_addresses: nil,
      )
      expect(form.save).to be false
    end

    it 'returns false if audit_comment is blank' do
      form = described_class.new(
        audit_user:,
        audit_comment: nil,
        email_addresses: 'candidate_1@email.address',
      )
      expect(form.save).to be false
    end

    it 'calls Support::Candidates::BulkUnsubscribeWorker with an array of email addresses' do
      allow(Support::Candidates::BulkUnsubscribeWorker).to receive(:perform_async)

      # White space is intentional to test that it is stripped
      form_email_addresses = "

      candidate_1@email.address
      candidate_2@email.address
      candidate_3@email.address

"

      form = described_class.new(
        audit_user:,
        audit_comment:,
        email_addresses: form_email_addresses,
      )
      form.save
      expect(Support::Candidates::BulkUnsubscribeWorker).to have_received(:perform_async)
        .with(
          audit_user.id,
          audit_comment,
          %w[candidate_1@email.address candidate_2@email.address candidate_3@email.address],
        )
    end
  end
end
