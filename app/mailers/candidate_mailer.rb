class CandidateMailer < ApplicationMailer
  def submit_application_email(application_form)
    @application_form = application_form

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: application_form.candidate.email_address,
              subject: t('submit_application_success.email.subject'))
  end
end
