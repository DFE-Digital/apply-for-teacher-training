class Healthchecks::NotifyCheck < OkComputer::Check
  def initialize(*, force_pass: false, **, &)
    @force_pass = force_pass
    super(*, **, &)
  end

  def check
    mark_message('Notify simulated pass, true status unknown') and return if @force_pass

    notify_client.send_email(
      email_address: 'simulate-delivered@notifications.service.gov.uk',
      template_id: ENV.fetch('GOVUK_NOTIFY_TEST_TEMPLATE_ID'),
    )

    mark_message 'Notify is working'
  rescue Notifications::Client::RequestError => e
    mark_failure
    mark_message "Notify email sending failed: #{e.message}"
  end

private

  def notify_client
    @notify_client ||= Notifications::Client.new(ENV.fetch('GOVUK_NOTIFY_API_KEY'))
  end
end
