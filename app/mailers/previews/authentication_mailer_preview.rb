class AuthenticationMailerPreview < ActionMailer::Preview
  def sign_up_email
    AuthenticationMailer.sign_up_email(to: "#{SecureRandom.hex}@example.com", token: SecureRandom.hex)
  end

  def sign_in_email
    AuthenticationMailer.sign_in_email(to: "#{SecureRandom.hex}@example.com", token: SecureRandom.hex)
  end
end
