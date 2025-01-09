require 'rails_helper'

RSpec.describe SupportInterface::Candidates::BulkUnsubscribeForm, type: :model do
  describe '#save' do
    it 'returns false if not valid' do
      form = described_class.new(email_addresses: nil)
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

      form = described_class.new(email_addresses: form_email_addresses)
      form.save
      expect(Support::Candidates::BulkUnsubscribeWorker).to have_received(:perform_async)
                                                              .with(%w[candidate_1@email.address candidate_2@email.address candidate_3@email.address])
    end
  end
end
