class CandidateMailer < ApplicationMailer
  def submit_application_email(to:, application_ref:)
    @application_ref = application_ref

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: to,
              subject: t('submit_application_success.email.subject'))
  end
end
