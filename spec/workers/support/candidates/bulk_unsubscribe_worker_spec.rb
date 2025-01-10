require 'rails_helper'

RSpec.describe Support::Candidates::BulkUnsubscribeWorker, :sidekiq do
  describe '#perform' do
    it 'chase references and notify candidates' do
      allow(SupportInterface::Candidates::BulkUnsubscribe).to receive(:bulk_unsubscribe)

      described_class.new.perform(%w[email_1@email.address email_2@email.address])

      expect(SupportInterface::Candidates::BulkUnsubscribe).to have_received(:bulk_unsubscribe)
                                                                  .with(%w[email_1@email.address email_2@email.address])
    end
  end
end
