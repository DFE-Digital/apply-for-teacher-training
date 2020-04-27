require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  include CourseOptionHelpers
  include TestHelpers::MailerSetupHelper

  subject(:mailer) { described_class }

  describe '.chase_reference' do
    let(:application_form) { build(:completed_application_form, references_count: 1, with_gces: true) }
    let(:reference) { application_form.application_references.first }
    let(:mail) { mailer.chase_reference(reference) }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(I18n.t!('candidate_mailer.chase_reference.subject', referee_name: reference.name))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include("Dear #{application_form.first_name}")
    end

    it 'sends an email containing the referee email' do
      expect(mail.body.encoded).to include(reference.email_address)
    end
  end

  shared_examples 'a new reference request mail with subject and content' do |reason, subject, content|
    let(:email) { described_class.send(:new_referee_request, @reference, reason: reason) }

    it 'sends an email with the correct subject' do
      expect(email.subject).to include(subject)
    end

    content.each do |key, expectation|
      it "sends an email containing the #{key} in the body" do
        expect(email.body).to include(expectation)
      end
    end
  end

  describe '.new_referee_request' do
    before do
      @reference = build_stubbed(
        :reference,
        name: 'Scott Knowles',
        email_address: 'ting@canpaint.com',
        application_form: build_stubbed(:application_form, first_name: 'Tyrell', last_name: 'Wellick'),
      )

      magic_link_stubbing(@reference.application_form.candidate)
    end

    context 'when referee has not responded' do
      it_behaves_like(
        'a new reference request mail with subject and content', :not_responded,
        I18n.t!('candidate_mailer.new_referee_request.not_responded.subject', referee_name: 'Scott Knowles'),
        'heading' => 'Dear Tyrell',
        'explanation' => I18n.t!('candidate_mailer.new_referee_request.not_responded.explanation', referee_name: 'Scott Knowles')
      )
    end

    context 'when referee has refused' do
      it_behaves_like(
        'a new reference request mail with subject and content', :refused,
        I18n.t!('candidate_mailer.new_referee_request.refused.subject', referee_name: 'Scott Knowles'),
        'heading' => 'Dear Tyrell',
        'explanation' => I18n.t!('candidate_mailer.new_referee_request.refused.explanation', referee_name: 'Scott Knowles')
      )
    end

    context 'when email address of referee has bounced' do
      it_behaves_like(
        'a new reference request mail with subject and content', :email_bounced,
        I18n.t!('candidate_mailer.new_referee_request.email_bounced.subject', referee_name: 'Scott Knowles'),
        'heading' => 'Dear Tyrell',
        'explanation' => "Our email requesting a reference didn’t reach Scott Knowles.\r\n\r\nWe emailed the referee using this address: ting@canpaint.com"
      )
    end
  end
end
