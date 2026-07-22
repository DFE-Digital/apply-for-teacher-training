class Support::SendNotifyTemplateWithAttachmentWorker
  include Sidekiq::Worker

  def perform(notify_request_id)
    request = SupportInterface::NotifySendRequest.find(notify_request_id)
    relation = request.email_addresses
    ArrayBatchDelivery.new(relation:, stagger_over: stagger_over(relation)).each do |batch_time, batch_email_addresses|
      Support::SendNotifyTemplateWithAttachmentBatchWorker.perform_at(
        batch_time,
        batch_email_addresses,
        request.id,
      )
    end
  end

private

  def stagger_over(relation)
    if relation.count > 3000
      (relation.count / 500).minutes
    else
      5.minutes
    end
  end
end
