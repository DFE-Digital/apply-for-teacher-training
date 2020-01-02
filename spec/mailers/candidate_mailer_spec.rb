require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe 'Send submit application email' do
    let(:mail) { mailer.submit_application_email(build_stubbed(:application_form, support_reference: 'SUPPORT-REFERENCE')) }

    before { mail.deliver_later }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('submit_application_success.email.subject'))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include('Application submitted')
    end

    it 'sends an email containing the support reference' do
      expect(mail.body.encoded).to include('SUPPORT-REFERENCE')
    end
  end

  describe 'Send reference chaser email' do
    let(:application_form) { create(:completed_application_form) }
    let(:reference) { application_form.application_references.first }
    let(:mail) { mailer.reference_chaser_email(application_form, reference) }

    before { mail.deliver_later }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('candidate_reference.subject.chaser', referee_name: reference.name))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include("Dear #{application_form.first_name}")
    end

    it 'sends an email containing the referee email' do
      expect(mail.body.encoded).to include(reference.email_address)
    end
  end

  describe 'Send survey email' do
    let(:candidate) { build_stubbed(:candidate) }
    let(:application_form) { build_stubbed(:application_form, candidate: candidate) }

    context 'when initial email' do
      let(:mail) { mailer.survey_email(application_form) }

      before { mail.deliver_later }

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('survey_emails.subject'))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include("Dear #{application_form.first_name}")
      end

      it 'sends an email with the link to the survey' do
        expect(mail.body.encoded).to include(t('survey_emails.survey_link'))
      end
    end
  end
end
