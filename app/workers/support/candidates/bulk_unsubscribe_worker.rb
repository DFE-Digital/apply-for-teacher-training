class Support::Candidates::BulkUnsubscribeWorker < ApplicationJob
  self.queue_adapter = :solid_queue

  def perform(audit_user_id, audit_comment, email_addresses = [])
    SupportInterface::Candidates::BulkUnsubscribe.bulk_unsubscribe(
      audit_user_id,
      audit_comment,
      email_addresses,
    )
  end
end
