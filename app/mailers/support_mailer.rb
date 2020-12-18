class SupportMailer < ApplicationMailer
  def confirm_sign_in(support_user, device:)
    @support_user = support_user
    @device = device

    notify_email(
      to: support_user.email_address,
      subject: 'New sign in to Support for Apply',
    )
  end

  def fallback_sign_in_email(support_user, token)
    @token = token

    notify_email(
      to: support_user.email_address,
      subject: t('authentication.sign_in.email.subject'),
    )
  end
end
