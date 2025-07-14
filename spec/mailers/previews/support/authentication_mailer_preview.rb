class Support::AuthenticationMailerPreview < ActionMailer::Preview
  def confirm_sign_in
    SupportMailer.confirm_sign_in(
      FactoryBot.build_stubbed(:support_user),
      device: {
        ip_address: Faker::Internet.ip_v4_address,
        user_agent: Faker::Internet.user_agent,
      },
    )
  end

  def fallback_sign_in_email
    SupportMailer.fallback_sign_in_email(
      FactoryBot.build_stubbed(:support_user),
      token: 'ABC-FOO',
    )
  end
end
