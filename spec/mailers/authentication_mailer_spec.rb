require 'rails_helper'

RSpec.describe AuthenticationMailer, type: :mailer do
  subject(:mailer) { described_class }

  let(:candidate) { create(:candidate, email_address: 'test@example.com') }

  describe '.sign_up_email' do
    let(:token) { 'blub' }
    let(:email) { mailer.sign_up_email(candidate: candidate, token: token) }

    before do
      allow(Encryptor).to receive(:encrypt).and_return('secret')
    end

    it_behaves_like(
      'a mail with subject and content',
      I18n.t('authentication.sign_up.email.subject'),
      'body' => 'Confirm your email address to apply for teacher training',
      'magic_link' => 'http://localhost:3000/candidate/sign-in/confirm?token=blub',
    )

    it 'sends a request with a Notify reference' do
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'example_env' do
        email.deliver_now
      end

      expect(email[:reference].value).to start_with("example_env-sign_up_email-#{candidate.id}")
    end
  end

  describe 'the candidate receives the sign in email containing the magic link' do
    let(:token) { 'blub' }
    let(:email) { mailer.sign_in_email(candidate: candidate, token: token) }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t('authentication.sign_in.email.subject'),
      'heading' => I18n.t('authentication.sign_in.email.subject'),
      'magic link' => 'http://localhost:3000/candidate/sign-in/confirm?token=blub',
    )
  end

  describe 'the candidate receives an email when they try to sign in without an existing account' do
    let(:email) { mailer.sign_in_without_account_email(to: 'test@example.com') }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t('authentication.sign_in_without_account.email.subject'),
      'heading' => 'You tried to sign in to apply for teacher training',
      'sign up link' => 'http://localhost:3000/candidate/sign-up',
    )
  end
end
