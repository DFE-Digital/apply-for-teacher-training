require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  subject(:mailer) { described_class }

  let(:application_form) { build_stubbed(:completed_application_form, :with_gcses, application_references: references, references_count: references.count) }
  let(:reference) { build_stubbed(:reference, name: 'Scott Knowles') }
  let(:references) { [reference] }

  describe '.chase_reference' do
    let(:email) { mailer.chase_reference(reference) }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.chase_reference.subject', referee_name: 'Scott Knowles'),
      'heading' => 'Scott Knowles has not responded yet',
    )
  end

  describe '.new_referee_request' do
    let(:email) { mailer.send(:new_referee_request, reference, reason: reason) }

    context 'when referee has not responded' do
      let(:reason) { :not_responded }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.new_referee_request.not_responded.subject', referee_name: 'Scott Knowles'),
        'heading' => 'Scott Knowles has not responded yet',
      )
    end

    context 'when referee has refused' do
      let(:reason) { :refused }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.new_referee_request.refused.subject', referee_name: 'Scott Knowles'),
        'heading' => 'Scott Knowles has declined your reference request',
      )
    end

    context 'when email address of referee has bounced' do
      let(:reason) { :email_bounced }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.new_referee_request.email_bounced.subject', referee_name: 'Scott Knowles'),
        'heading' => 'Referee request did not reach Scott Knowles',
      )
    end
  end

  describe '.reference_received' do
    let(:email) { mailer.send(:reference_received, application_form.application_references.first) }
    let(:reference) { build_stubbed(:reference, :feedback_provided, name: 'Scott Knowles') }

    context 'when one reference has been received' do
      let(:other_reference) { build_stubbed(:reference, :feedback_requested, name: 'Kara Thrace') }
      let(:references) { [reference, other_reference] }

      it_behaves_like(
        'a mail with subject and content',
        'You have a reference from Scott Knowles',
        'request other' => 'You need to get another reference',
      )
    end

    context 'when two references have been received' do
      let(:email) { mailer.send(:reference_received, reference) }

      let(:application_form) { build_stubbed(:application_form, application_references: [other_reference]) }
      let(:reference) { build_stubbed(:reference, :feedback_provided, name: 'Scott Knowles', application_form: application_form) }
      let(:other_reference) { build_stubbed(:reference, :feedback_provided, name: 'William Adama') }

      before do
        allow(application_form).to receive(:enough_references_have_been_provided?).and_return(true)
      end

      it_behaves_like(
        'a mail with subject and content',
        'You have a reference from Scott Knowles',
        'request other' => 'You’ve got 2 references back now.',
      )
    end
  end
end
