require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  include CourseOptionHelpers
  include TestHelpers::MailerSetupHelper

  subject(:mailer) { described_class }

  describe '.chase_reference' do
    let(:application_form) { build(:completed_application_form, references_count: 1, with_gcses: true) }
    let(:reference) { application_form.application_references.first }
    let(:mail) { mailer.chase_reference(reference) }

    it 'sends an email with the correct subject' do
      expect(mail.subject).to include(I18n.t!('candidate_mailer.chase_reference.subject', referee_name: reference.name))
    end

    it 'sends an email with the correct heading' do
      expect(mail.body.encoded).to include("#{reference.name} has not responded yet")
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
        'heading' => 'Scott Knowles has not responded yet'
      )
    end

    context 'when referee has refused' do
      it_behaves_like(
        'a new reference request mail with subject and content', :refused,
        I18n.t!('candidate_mailer.new_referee_request.refused.subject', referee_name: 'Scott Knowles'),
        'heading' => 'Scott Knowles has declined your reference request'
      )
    end

    context 'when email address of referee has bounced' do
      it_behaves_like(
        'a new reference request mail with subject and content', :email_bounced,
        I18n.t!('candidate_mailer.new_referee_request.email_bounced.subject', referee_name: 'Scott Knowles'),
        'heading' => 'Referee request did not reach Scott Knowles'
      )
    end
  end

  describe '.reference_received' do
    it 'sends an email with the correct body if one reference complete' do
      application_form = create(:completed_application_form, :with_completed_references)
      create(:reference, :complete, application_form: application_form)
      create(:reference, :requested, application_form: application_form)

      email = described_class.send(:reference_received, application_form.application_references.first)
      expect(email.body).to include('You need to get another reference')
    end

    it 'sends an email with the correct body if two references complete' do
      application_form = create(:completed_application_form, :with_completed_references)
      create(:reference, :complete, application_form: application_form)
      create(:reference, :complete, application_form: application_form)

      email = described_class.send(:reference_received, application_form.application_references.first)
      expect(email.body).to include('You’ve got 2 references back now.')
    end
  end
end
