class Healthchecks::NotifyCheck < OkComputer::Check
  def initialize(*, force_pass: false, **, &)
    @force_pass = force_pass
    super(*, **, &)
  end

  def check
    mark_message('Notify simulated pass, true status unknown') and return if @force_pass

    notify_client.send_email(
      email_address: 'simulate-delivered@notifications.service.gov.uk',
      template_id: ApplicationMailer::GENERIC_NOTIFY_TEMPLATE,
      personalisation: {
        subject: 'Notify check',
        body: 'This is a test email to check Notify is working',
      },
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
