class RefereeMailer < ApplicationMailer
  def reference_request_email(application_form, reference)
    @application_form = application_form
    @reference = reference

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: reference.email_address,
              subject: t('reference_request.email.subject'))
  end
end
