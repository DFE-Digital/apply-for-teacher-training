require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe 'Send submit application email' do
    let(:mail) { mailer.submit_application_email(to: 'test@example.com', application_ref: 'APPLICATION-REF') }

    before { mail.deliver! }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('submit_application_success.email.subject'))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include('Thank you for completing your teacher training application')
    end

    it 'sends an email containing the application_ref' do
      expect(mail.body.encoded).to include('APPLICATION-REF')
    end
  end
end
