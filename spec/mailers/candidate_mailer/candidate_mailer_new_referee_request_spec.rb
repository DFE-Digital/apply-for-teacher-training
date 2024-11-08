require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.new_referee_request' do
    let(:referee) { create(:reference, name: 'Jolyne Doe', application_form:) }
    let(:email) { described_class.send(:new_referee_request, referee, reason:) }
    let(:application_choices) { [create(:application_choice, :pending_conditions, course_option:)] }

    context 'when referee has not responded' do
      let(:reason) { :not_responded }

      it_behaves_like(
        'a mail with subject and content',
        'Jolyne Doe has not replied to your request for a reference',
        'heading' => 'They have not replied yet',
        'description' => 'You asked Jolyne Doe for a reference for your teacher training application. They have not replied yet.',
        'urgency' => 'It is important that Arithmetic College receives your references as soon as possible.',
      )
    end

    context 'when referee has refused' do
      let(:reason) { :refused }

      it_behaves_like(
        'a mail with subject and content',
        'Jolyne Doe is unable to give you a reference',
        body: 'Jolyne Doe has said that they’re unable to give you a reference.',
        'urgency' => 'It is important that Arithmetic College receives your references as soon as possible.',
      )
    end

    context 'when email address of referee has bounced' do
      let(:reason) { :email_bounced }

      it_behaves_like(
        'a mail with subject and content',
        'Jolyne Doe has not received your request for a reference',
        body: 'Your request did not reach Jolyne Doe',
        'reminder' => 'You asked Jolyne Doe for a reference for your teacher training application.',
      )
    end
  end
end
