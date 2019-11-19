class ApplicationMailer < Mail::Notify::Mailer
  rescue_from Notifications::Client::BadRequestError, with: :report_notify_error

  def report_notify_error(e)
    Raven.capture_exception(e)
  end

  GENERIC_NOTIFY_TEMPLATE = '2744ea53-34f1-431f-8173-8388fadd826a'.freeze
end
