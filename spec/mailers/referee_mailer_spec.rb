require 'rails_helper'

RSpec.describe RefereeMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe 'Send request reference email' do
    let(:application_form) { build(:completed_application_form) }
    let(:reference) { application_form.references.first }
    let(:mail) { mailer.reference_request_email(application_form, reference) }

    before { mail.deliver_now }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('reference_request.email.subject'))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include('provide a reference for')
    end
  end
end
