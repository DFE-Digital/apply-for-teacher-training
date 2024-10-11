require 'rails_helper'

RSpec.describe SandboxInterceptor do
  context 'In sandbox mode', :sandbox do
    context 'when rails_mailer is set to provider_mailer' do
      it 'aborts delivery by default' do
        message = email_with_mailer_and_template('provider_mailer', 'anything')

        described_class.delivering_email(message)

        expect(message.perform_deliveries).to be false
      end

      it 'still permits fallback_sign_in_email' do
        message = email_with_mailer_and_template('provider_mailer', 'fallback_sign_in_email')

        described_class.delivering_email(message)

        expect(message.perform_deliveries).to be true
      end

      it 'still permits permissions granted' do
        message = email_with_mailer_and_template('provider_mailer', 'permissions_granted')

        described_class.delivering_email(message)

        expect(message.perform_deliveries).to be true
      end
    end

    it 'allows delivery when rails_mailer is not set to provider_mailer' do
      message = email_with_mailer_and_template('authentication_mailer', 'sign_in_email')

      described_class.delivering_email(message)

      expect(message.perform_deliveries).to be true
    end
  end

  it 'does nothing outside sandbox mode' do
    message = email_with_mailer_and_template('provider_mailer', 'anything')

    described_class.delivering_email(message)

    expect(message.perform_deliveries).to be true
  end

  # this reflects the standard format emitted by ApplicationMailer
  def email_with_mailer_and_template(mailer, template)
    Mail::Message.new(to: ['test@example.com'], subject: 'Foo') do |message|
      message.instance_variable_set(:@rails_mailer, mailer)
      message.instance_variable_set(:@rails_mail_template, template)
      message.class.send(:attr_reader, :rails_mailer)
      message.class.send(:attr_reader, :rails_mail_template)
    end
  end
end
