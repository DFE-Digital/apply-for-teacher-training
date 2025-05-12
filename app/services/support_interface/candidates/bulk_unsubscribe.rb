class SupportInterface::Candidates::BulkUnsubscribe
  def self.bulk_unsubscribe(email_addresses)
    new(email_addresses).bulk_unsubscribe
  end

  def initialize(email_addresses = [])
    @email_addresses = Array.wrap(email_addresses)
  end

  def bulk_unsubscribe
    email_addresses_for_unsubscribe = email_addresses.map(&:strip).compact_blank!

    ::Candidate.where(email_address: email_addresses_for_unsubscribe).in_batches do |candidates|
      candidates.update_all(unsubscribed_from_emails: true)
    end
  end

private

  attr_reader :email_addresses
end
