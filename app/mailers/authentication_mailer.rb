class AuthenticationMailer < ApplicationMailer
  def sign_up_email(to:, token:)
    @magic_link = "#{candidate_interface_application_form_url}?token=#{token}"

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: to,
              subject: t('authentication.sign_up.email.subject'))
  end

  def sign_in_email(to:, token:)
    @magic_link = "#{candidate_interface_application_form_url}?token=#{token}"

    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: to,
              subject: t('authentication.sign_in.email.subject'))
  end

  def sign_in_without_account_email(to:)
    view_mail(GENERIC_NOTIFY_TEMPLATE,
              to: to,
              subject: t('authentication.sign_in_without_account.email.subject'))
  end
end
