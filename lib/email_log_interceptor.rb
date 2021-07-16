class EmailLogInterceptor
  def self.delivering_email(mail)
    notify_reference = mail.header['reference']&.value

    unless notify_reference
      notify_reference = generate_reference
      mail.header['reference'] = notify_reference
    end

    logged_email = Email.create!(
      to: mail.to.first,
      subject: mail.subject,
      body: mail.body.encoded,
      notify_reference: notify_reference,
      application_form_id: mail.header['application_form_id']&.value,
      mailer: mail.header['rails_mailer'].value,
      mail_template: mail.header['rails_mail_template'].value,
      delivery_status: mail.perform_deliveries ? 'pending' : 'skipped',
    )

    mail.header['email-log-id'] = logged_email.id
  rescue StandardError => e
    # Email logging should not stop the actual email sending
    Rails.logger.info("Exception occured when trying to log email: #{e.message}")
    Sentry.capture_exception(e)
  end

  def self.generate_reference
    "#{HostingEnvironment.environment_name}-#{SecureRandom.hex}"
  end
end
