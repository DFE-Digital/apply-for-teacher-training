class AuthenticationMailerPreview < ActionMailer::Preview
  def sign_up_email
    AuthenticationMailer.sign_up_email(candidate: FactoryBot.build_stubbed(:candidate), token: SecureRandom.hex)
  end

  def sign_in_email_without_account_email
    AuthenticationMailer.sign_in_without_account_email(to: FactoryBot.build_stubbed(:candidate).email_address)
  end

  def sign_in_email
    AuthenticationMailer.sign_in_email(candidate: FactoryBot.create(:candidate), token: SecureRandom.hex)
  end
end
