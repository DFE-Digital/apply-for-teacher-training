class TTApplicationMailer < Mail::Notify::Mailer
  GENERIC_NOTIFY_TEMPLATE = '2744ea53-34f1-431f-8173-8388fadd826a'.freeze

  def send_application(to:, candidate_email:)
    @candidate_email = candidate_email

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: to,
              subject: 'Application submitted')
  end
end
