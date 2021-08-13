require 'rails_helper'

RSpec.describe SandboxInterceptor do
  context 'In sandbox mode', sandbox: true do
    context 'when rails_mailer is set to provider_mailer' do
      it 'aborts delivery by default' do
        message = email_with_mailer_and_template_headers('provider_mailer', 'anything')

        described_class.delivering_email(message)

        expect(message.perform_deliveries).to be false
      end

      it 'still permits fallback_sign_in_email' do
        message = email_with_mailer_and_template_headers('provider_mailer', 'fallback_sign_in_email')

        described_class.delivering_email(message)

        expect(message.perform_deliveries).to be true
      end

      it 'still permits account_created' do
        message = email_with_mailer_and_template_headers('provider_mailer', 'account_created')

        described_class.delivering_email(message)

        expect(message.perform_deliveries).to be true
      end
    end

    it 'allows delivery when rails_mailer is not set to provider_mailer' do
      message = email_with_mailer_and_template_headers('authentication_mailer', 'sign_in_email')

      described_class.delivering_email(message)

      expect(message.perform_deliveries).to be true
    end
  end

  it 'does nothing outside sandbox mode' do
    message = email_with_mailer_and_template_headers('provider_mailer', 'anything')

    described_class.delivering_email(message)

    expect(message.perform_deliveries).to be true
  end

  # this reflects the standard format emitted by ApplicationMailer
  def email_with_mailer_and_template_headers(mailer, template)
    Mail::Message.new(to: ['test@example.com'], subject: 'Foo', headers: { rails_mailer: mailer, rails_mail_template: template })
  end
end
