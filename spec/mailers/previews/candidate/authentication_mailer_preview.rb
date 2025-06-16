class Candidate::AuthenticationMailerPreview < ActionMailer::Preview
  def sign_up_email
    AuthenticationMailer.sign_up_email(candidate: FactoryBot.build_stubbed(:candidate), token: SecureRandom.hex)
  end

  def sign_in_email_without_account_email
    AuthenticationMailer.sign_in_without_account_email(to: FactoryBot.build_stubbed(:candidate).email_address)
  end

  def sign_in_email
    candidate = FactoryBot.create(:candidate)
    AuthenticationMailer.sign_in_email(candidate:, token: SecureRandom.hex, email_address: candidate.email_address)
  end

  def duplicate_match_email
    application_form = FactoryBot.build(:application_form, first_name: 'Tester', submitted_at: Time.zone.now)

    CandidateMailer.duplicate_match_email(application_form)
  end
end
