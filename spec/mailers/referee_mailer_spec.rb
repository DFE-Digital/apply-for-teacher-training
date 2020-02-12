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
        references_count: 1,
        with_gces: true,
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

    it 'sends a request with a Notify reference' do
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'example_env' do
        mail.deliver_now
      end

      expect(mail[:reference].value).to eq("example_env-reference_request-#{reference.id}")
    end
  end

  describe 'Send chasing reference email' do
    let(:first_application_choice) { create(:application_choice) }
    let(:second_application_choice) { create(:application_choice) }
    let(:third_application_choice) { create(:application_choice) }
    let(:application_form) do
      create(
        :completed_application_form,
        with_gces: true,
        first_name: 'Harry',
        last_name: 'Potter',
        application_choices_count: 0,
        references_count: 1,
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

  describe 'Send reference confirmation email' do
    let(:reference) { build_stubbed(:reference) }
    let(:application_form) do
      build_stubbed(
        :application_form,
        first_name: 'Elliot',
        last_name: 'Alderson',
        application_references: [reference],
      )
    end

    let(:mail) { mailer.reference_confirmation_email(application_form, reference) }

    before { mail.deliver_later }

    it 'sends an email to the provided referee' do
      expect(mail.to).to include(reference.email_address)
    end

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(t('reference_confirmation_email.subject', candidate_name: 'Elliot Alderson'))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include("Dear #{reference.name}")
    end
  end
end
