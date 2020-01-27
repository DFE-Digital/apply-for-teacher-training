class ProviderMailer < ApplicationMailer
  def account_created(provider_user)
    @provider_user = provider_user

    view_mail(
      GENERIC_NOTIFY_TEMPLATE,
      to: @provider_user.email_address,
      subject: t('provider_account_created.email.subject'),
    )
  end
end
