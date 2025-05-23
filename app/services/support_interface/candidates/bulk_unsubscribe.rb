class SupportInterface::Candidates::BulkUnsubscribe
  def self.bulk_unsubscribe(audit_user_id, audit_comment, email_addresses)
    new(audit_user_id, audit_comment, email_addresses).bulk_unsubscribe
  end

  def initialize(audit_user_id, audit_comment, email_addresses = [])
    @audit_user = SupportUser.find_by(id: audit_user_id)
    @audit_comment = audit_comment
    @email_addresses = Array.wrap(email_addresses)
  end

  def bulk_unsubscribe
    email_addresses_for_unsubscribe = email_addresses.map(&:strip).compact_blank!

    ::Candidate.where(email_address: email_addresses_for_unsubscribe).in_batches do |candidates|
      ActiveRecord::Base.transaction do
        Audited.audit_class.as_user(audit_user) do
          candidates.each do |candidate|
            candidate.update(
              unsubscribed_from_emails: true,
              audit_comment:,
            )
          end
        end
      end
    end
  end

private

  attr_reader :audit_user, :audit_comment, :email_addresses
end
