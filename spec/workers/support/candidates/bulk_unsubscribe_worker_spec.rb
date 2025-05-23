require 'rails_helper'

RSpec.describe Support::Candidates::BulkUnsubscribeWorker, :sidekiq do
  describe '#perform' do
    it 'chase references and notify candidates' do
      allow(SupportInterface::Candidates::BulkUnsubscribe).to receive(:bulk_unsubscribe)
      audit_user_id = 1
      audit_comment = 'audit comment'

      described_class.new.perform(
        audit_user_id,
        audit_comment,
        %w[email_1@email.address email_2@email.address],
      )

      expect(SupportInterface::Candidates::BulkUnsubscribe).to have_received(:bulk_unsubscribe)
      .with(
        audit_user_id,
        audit_comment,
        %w[email_1@email.address email_2@email.address],
      )
    end
  end
end
