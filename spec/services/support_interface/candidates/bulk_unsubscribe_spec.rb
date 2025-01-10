require 'rails_helper'

RSpec.describe SupportInterface::Candidates::BulkUnsubscribe do
  describe '.bulk_unsubscribe' do
    it 'unsubscribes the given email addresses' do
      candidate1 = create(:candidate, email_address: 'candidate_1@email.address')
      candidate2 = create(:candidate, email_address: 'candidate_2@email.address')
      candidate3 = create(:candidate, email_address: 'candidate_3@email.address')

      described_class.bulk_unsubscribe([candidate1.email_address, candidate2.email_address])

      expect(candidate1.reload).to be_unsubscribed_from_emails
      expect(candidate2.reload).to be_unsubscribed_from_emails
      expect(candidate3.reload).not_to be_unsubscribed_from_emails
    end

    it 'removes any leading or trailing whitespace from the email addresses' do
      candidate1 = create(:candidate, email_address: 'candidate_1@email.address')
      candidate2 = create(:candidate, email_address: 'candidate_2@email.address')

      described_class.bulk_unsubscribe([" #{candidate1.email_address} ", " #{candidate2.email_address} ", '  '])

      expect(candidate1.reload).to be_unsubscribed_from_emails
      expect(candidate2.reload).to be_unsubscribed_from_emails
    end

    it 'can handle unknown email addresses' do
      candidate1 = create(:candidate, email_address: 'candidate_1@email.address')
      candidate2 = create(:candidate, email_address: 'candidate_2@email.address')

      described_class.bulk_unsubscribe(['unknown@email.address',
                                        'this is not an email address',
                                        'candidate_1@email.address'])
      expect(candidate1.reload).to be_unsubscribed_from_emails
      expect(candidate2.reload).not_to be_unsubscribed_from_emails
    end
  end
end
