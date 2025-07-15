class Provider::AuthenticationMailerPreview < ActionMailer::Preview
  def confirm_sign_in
    ProviderMailer.confirm_sign_in(
      FactoryBot.build_stubbed(:provider_user),
      timestamp: Time.zone.now,
    )
  end

  def fallback_sign_in_email
    ProviderMailer.fallback_sign_in_email(
      FactoryBot.build_stubbed(:provider_user),
      token: 'ABC-FOO',
    )
  end
end
