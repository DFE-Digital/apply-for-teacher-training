class SupportMailerPreview < ActionMailer::Preview
  def confirm_sign_in
    SupportMailer.confirm_sign_in(
      FactoryBot.build_stubbed(:support_user),
      device: {
        ip_address: Faker::Internet.ip_v4_address,
        user_agent: Faker::Internet.user_agent,
      },
    )
  end
end
