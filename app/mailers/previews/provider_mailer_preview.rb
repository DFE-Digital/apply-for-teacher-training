class ProviderMailerPreview < ActionMailer::Preview
  def account_created_email
    provider_user = FactoryBot.build :provider_user

    ProviderMailer.account_created(provider_user)
  end
end
