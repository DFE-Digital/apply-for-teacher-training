class ApplicationMailer < Mail::Notify::Mailer
  GENERIC_NOTIFY_TEMPLATE = '2744ea53-34f1-431f-8173-8388fadd826a'.freeze

  rescue_from Notifications::Client::RequestError do
    # WARNING: this needs to be a block, otherwise the exception won't be
    # re-raised and we won't be notified via Sentry, and the job won't retry.
    #
    # @see https://github.com/rails/rails/issues/39018
    email = Email.find(headers['email-log-id'].to_s)
    email.update!(delivery_status: 'notify_error')
    raise
  end

  def notify_email(headers)
    headers = headers.merge(rails_mailer: mailer_name, rails_mail_template: action_name)
    view_mail(GENERIC_NOTIFY_TEMPLATE, headers)
  end
end
