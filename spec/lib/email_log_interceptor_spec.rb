require 'rails_helper'

RSpec.describe EmailLogInterceptor do
  describe '.delivering_email' do
    it 'marks non-delivered mails as skipped' do
      mail = generate_email
      mail.perform_deliveries = false

      described_class.delivering_email(mail)

      expect(Email.last.delivery_status).to eql('skipped')
    end

    it 'marks mail that we intend to deliver as pending' do
      mail = generate_email
      mail.perform_deliveries = true

      described_class.delivering_email(mail)

      expect(Email.last.delivery_status).to eql('pending')
    end

    def generate_email
      Mail::Message.new(to: ['test@example.com'], subject: 'Foo', headers: { rails_mailer: 'foo', rails_mail_template: 'bar' })
    end
  end
end
