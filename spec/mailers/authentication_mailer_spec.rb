require 'rails_helper'

RSpec.describe AuthenticationMailer, type: :mailer do
  subject(:mailer) { described_class }

  let(:candidate) { create(:candidate, email_address: 'test@example.com') }

  describe '.sign_up_email' do
    let(:token) { 'blub' }
    let(:mail) { mailer.sign_up_email(candidate: candidate, token: token) }

    before { mail.deliver_later }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('authentication.sign_up.email.subject'))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include(t('authentication.sign_up.email.subject'))
    end

    it 'sends an email with a magic link' do
      expect(mail.body.encoded).to include("http://localhost:3000/candidate/authenticate?token=#{token}")
    end

    it 'sends a request with a Notify reference' do
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'example_env' do
        mail.deliver_now
      end

      expect(mail[:reference].value).to eq("example_env-sign_up_email-#{candidate.id}")
    end
  end

  describe 'the candidate receives the sign in email containing the magic link' do
    let(:token) { 'blub' }
    let(:mail) { mailer.sign_in_email(candidate: candidate, token: token) }

    before { mail.deliver_later }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('authentication.sign_in.email.subject'))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include(t('authentication.sign_in.email.subject'))
    end

    it 'sends an email with a magic link' do
      expect(mail.body.encoded).to include("http://localhost:3000/candidate/authenticate?token=#{token}")
    end
  end

  describe 'the candidate recieves an email when they try to sign in without an existing account' do
    let(:mail) { mailer.sign_in_without_account_email(to: 'test@example.com') }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('authentication.sign_in_without_account.email.subject'))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include(t('authentication.sign_in_without_account.email.subject'))
    end

    it 'sends an email with a link to sign up' do
      expect(mail.body.encoded).to include(candidate_interface_sign_up_url)
    end
  end
end
