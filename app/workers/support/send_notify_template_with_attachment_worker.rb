class Support::SendNotifyTemplateWithAttachmentWorker
  include Sidekiq::Worker

  BATCH_SIZE = 120

  def perform(notify_request_id)
    request = SupportInterface::NotifySendRequest.find(notify_request_id)
    ArrayBatchDelivery.new(relation: request.email_addresses, stagger_over: 12.hours, batch_size: BATCH_SIZE).each do |batch_time, batch_email_addresses|
      Support::SendNotifyTemplateWithAttachmentBatchWorker.perform_at(
        batch_time,
        batch_email_addresses,
        request.id,
      )
    end
  end
end
