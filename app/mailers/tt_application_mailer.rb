class TTApplicationMailer < ApplicationMailer
  def send_application(to:, candidate_email:)
    @candidate_email = candidate_email

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: to,
              subject: 'Application submitted')
  end
end
