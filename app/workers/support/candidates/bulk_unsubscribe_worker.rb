# frozen_string_literal: true

class Support::Candidates::BulkUnsubscribeWorker
  include Sidekiq::Worker

  def perform(audit_user_id, audit_comment, email_addresses = [])
    SupportInterface::Candidates::BulkUnsubscribe.bulk_unsubscribe(
      audit_user_id,
      audit_comment,
      email_addresses,
    )
  end
end
