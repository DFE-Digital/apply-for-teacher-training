require 'rails_helper'

RSpec.describe RefereeMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe 'Send request reference email' do
    let(:application_form) { create(:completed_application_form, first_name: 'Harry', last_name: 'Potter') }
    let(:reference) { application_form.references.first }
    let(:candidate_name) { "#{application_form.first_name} #{application_form.last_name}" }
    let(:mail) { mailer.reference_request_email(application_form, reference) }

    before { mail.deliver_now }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('reference_request.email.subject', candidate_name: candidate_name))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include("give a reference for #{candidate_name}")
    end

    it 'sends an email with a link to a prefilled Google form' do
      body = mail.body.encoded
      expect(body).to include(t('reference_request.google_form_url'))
      expect(body).to include("=#{reference.id}")
      expect(body).to include("=#{CGI.escape(reference.email_address)}")
    end

    it 'encodes spaces as %20 rather than + in the Google form parameters for correct prefilling' do
      expect(mail.body.encoded).to include("=#{candidate_name.gsub(' ', '%20')}")
      expect(mail.body.encoded).to include("=#{reference.name.gsub(' ', '%20')}")
    end

    context 'an email containing a +' do
      let(:reference) { build(:reference, email_address: 'email+email@email.com') }

      it 'does not strip the plus from the email address' do
        expect(mail.body.encoded).to include("=#{CGI.escape('email+email@email.com')}")
      end
    end
  end
end
