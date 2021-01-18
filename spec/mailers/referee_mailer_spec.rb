require 'rails_helper'
RSpec.describe RefereeMailer, type: :mailer do
  subject(:mailer) { described_class }

  let(:application_form) { build_stubbed(:application_form, first_name: 'Elliot', last_name: 'Alderson') }
  let(:reference) do
    build_stubbed(:reference, name: 'Jane',
                              email_address: 'jane@education.gov.uk',
                              application_form: application_form)
  end

  before do
    allow(reference).to receive(:refresh_feedback_token!).and_return('raw_token')
  end

  describe 'Send request reference email' do
    let(:email) { mailer.reference_request_email(reference) }

    it 'sends an email with a link to the reference form' do
      expect(email.body).to include('/reference?token=raw_token')
    end

    it 'sends a request with a Notify reference' do
      ClimateControl.modify HOSTING_ENVIRONMENT_NAME: 'example_env' do
        email.deliver_now
      end

      expect(email[:reference].value).to start_with("example_env-reference_request-#{reference.id}")
    end
  end

  describe 'Send chasing reference email' do
    let(:email) { mailer.reference_request_chaser_email(application_form, reference) }

    it 'sends an email with a link to the reference form' do
      expect(email.body).to include('/reference?token=raw_token')
    end
  end

  describe 'Send reference confirmation email' do
    let(:email) { mailer.reference_confirmation_email(application_form, reference) }

    it 'sends an email to the provided referee' do
      expect(email.to).to include(reference.email_address)
    end

    it_behaves_like(
      'a mail with subject and content',
      I18n.t('reference_confirmation_email.subject', candidate_name: 'Elliot Alderson'),
      'heading' => 'Dear Jane',
    )
  end

  describe 'Send reference cancelled email' do
    let(:email) { mailer.reference_cancelled_email(reference) }

    it 'sends an email to the provided referee' do
      expect(email.to).to include(reference.email_address)
    end

    it_behaves_like(
      'a mail with subject and content',
      I18n.t('reference_cancelled_email.subject', candidate_name: 'Elliot Alderson'),
      'heading' => 'Dear Jane',
    )
  end

  describe 'Send reference_request_chase_again_email email' do
    let(:email) { mailer.reference_request_chase_again_email(reference) }

    it 'sends an email to the provided referee' do
      expect(email.to).to include('jane@education.gov.uk')
    end

    it_behaves_like(
      'a mail with subject and content',
      I18n.t('referee_mailer.reference_request.subject.final', candidate_name: 'Elliot Alderson'),
      'heading' => 'Dear Jane',
      'reference link' => '/reference?token=raw_token',
    )
  end
end
