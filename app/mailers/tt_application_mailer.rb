class TTApplicationMailer < Mail::Notify::Mailer
  GENERIC_NOTIFY_TEMPLATE = 'b357c7b4-7e7d-4f59-a97d-301758a13eb6'.freeze

  def send_application(to:, candidate_email:)
    @candidate_email = candidate_email

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: to,
              subject: 'Application submitted')
  end
end
