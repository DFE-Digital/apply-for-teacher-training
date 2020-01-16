require 'rails_helper'
RSpec.describe RefereeMailer, type: :mailer do
  subject(:mailer) { described_class }

  describe 'Send request reference email' do
    let(:first_application_choice) { create(:application_choice) }
    let(:second_application_choice) { create(:application_choice) }
    let(:third_application_choice) { create(:application_choice) }
    let(:application_form) do
      create(
        :completed_application_form,
        first_name: 'Harry',
        last_name: "O'Potter",
        application_choices_count: 0,
        application_choices: [
          first_application_choice,
          second_application_choice,
          third_application_choice,
        ],
      )
    end
    let(:reference) { application_form.application_references.first }
    let(:candidate_name) { "#{application_form.first_name} #{application_form.last_name}" }
    let(:mail) { mailer.reference_request_email(application_form, reference) }

    it 'sends an email with a link to the reference form' do
      mail.deliver_now
      body = mail.body.encoded
      expect(body).to include(referee_interface_reference_feedback_url(token: ''))
    end

    it 'sends a request with a notify reference' do
      mail.deliver_now
      expect(mail[:reference].value).to eq("#{Rails.env}-reference_request-#{reference.id}")
    end
  end

  describe 'Send chasing reference email' do
    let(:first_application_choice) { create(:application_choice) }
    let(:second_application_choice) { create(:application_choice) }
    let(:third_application_choice) { create(:application_choice) }
    let(:application_form) do
      create(
        :completed_application_form,
        first_name: 'Harry',
        last_name: 'Potter',
        application_choices_count: 0,
        application_choices: [
          first_application_choice,
          second_application_choice,
          third_application_choice,
        ],
      )
    end
    let(:reference) { application_form.application_references.first }
    let(:candidate_name) { "#{application_form.first_name} #{application_form.last_name}" }
    let(:mail) { mailer.reference_request_chaser_email(application_form, reference) }

    it 'sends an email with a link to the reference form' do
      mail.deliver_now
      body = mail.body.encoded
      expect(body).to include(referee_interface_reference_feedback_url(token: ''))
    end
  end

  describe 'Send survey email' do
    let(:reference) { build_stubbed(:reference) }
    let(:application_form) do
      build_stubbed(
        :application_form,
        first_name: 'Elliot',
        last_name: 'Alderson',
        application_references: [reference],
      )
    end

    context 'when initial email' do
      let(:mail) { mailer.survey_email(application_form, reference) }

      before { mail.deliver_later }

      it 'sends an email to the provided referee' do
        expect(mail.to).to include(reference.email_address)
      end

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('survey_emails.subject.initial'))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include("Dear #{reference.name}")
      end

      it 'sends an email with the correct thank you message' do
        expect(mail.body.encoded).to include(t('survey_emails.thank_you.referee', candidate_name: 'Elliot Alderson'))
      end

      it 'sends an email with the link to the survey' do
        expect(mail.body.encoded).to include(t('survey_emails.survey_link'))
      end
    end

    context 'when chaser email' do
      let(:mail) { mailer.survey_chaser_email(reference) }

      before { mail.deliver_later }

      it 'sends an email with the correct subject' do
        expect(mail.subject).to include(t('survey_emails.subject.chaser'))
      end

      it 'sends an email with the correct heading' do
        expect(mail.body.encoded).to include("Dear #{reference.name}")
      end

      it 'sends an email with the link to the survey' do
        expect(mail.body.encoded).to include(t('survey_emails.survey_link'))
      end
    end
  end
end
