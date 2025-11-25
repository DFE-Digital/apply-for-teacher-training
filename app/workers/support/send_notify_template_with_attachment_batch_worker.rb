class Support::SendNotifyTemplateWithAttachmentBatchWorker
  include Sidekiq::Worker

  def perform(email_addresses, notify_request_id)
    request = SupportInterface::NotifySendRequest.find(notify_request_id)
    request.file.open do |file|
      link_to_file = Notifications.prepare_upload(file)
      email_addresses.each do |email_address|
        notify_client.send_email(
          email_address:,
          template_id: request.template_id,
          personalisation: {
            link_to_file:,
          },
        )
      end
    end
  end

private

  def notify_client
    @notify_client ||= Notifications::Client.new(ENV.fetch('GOVUK_NOTIFY_API_KEY'))
  end
end
