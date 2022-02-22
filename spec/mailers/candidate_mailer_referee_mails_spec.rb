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
        body: 'Scott Knowles has declined your reference request',
      )
    end

    context 'when email address of referee has bounced' do
      let(:reason) { :email_bounced }

      it_behaves_like(
        'a mail with subject and content',
        I18n.t!('candidate_mailer.new_referee_request.email_bounced.subject', referee_name: 'Scott Knowles'),
        body: 'Your referee request did not reach Scott Knowles',
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
        'request other' => 'You need another reference',
      )
    end

    context 'when a second reference is received but none are selected' do
      let(:email) { mailer.send(:reference_received, reference) }

      let(:application_form) { build(:application_form) }
      let(:reference) { build(:reference, :feedback_provided, name: 'Scott Knowles', application_form: application_form) }
      let(:other_reference) { build(:reference, :feedback_provided, name: 'William Adama', application_form: application_form) }

      before do
        application_form.application_references = [reference, other_reference]
      end

      it_behaves_like(
        'a mail with subject and content',
        'You have a reference from Scott Knowles',
        'request other' => 'You have enough references to send your application to training providers.',
      )
    end

    context 'when a third reference is received but none are selected' do
      let(:email) { mailer.send(:reference_received, reference) }

      let(:application_form) { build(:application_form) }
      let(:reference) { build(:reference, :feedback_provided, name: 'Scott Knowles', application_form: application_form) }
      let(:second_reference) { build(:reference, :feedback_provided, name: 'William Adama', application_form: application_form) }
      let(:third_reference) { build(:reference, :feedback_provided, name: 'Kara Thrace', application_form: application_form) }

      before do
        application_form.application_references = [reference, second_reference, third_reference]
      end

      it_behaves_like(
        'a mail with subject and content',
        'You have a reference from Scott Knowles',
        'request other' => 'You have more than enough references to send your application to training providers.',
      )
    end

    context 'when two references have been selected and another is received' do
      let(:email) { mailer.send(:reference_received, reference) }

      let(:application_form) { build(:application_form) }

      let(:first_selected_reference) { build(:reference, :feedback_provided, selected: true, application_form: application_form) }
      let(:second_selected_reference) { build(:reference, :feedback_provided, selected: true, application_form: application_form) }
      let(:reference) { build(:reference, :feedback_provided, name: 'Scott Knowles', application_form: application_form) }

      before do
        application_form.application_references = [first_selected_reference, second_selected_reference]
      end

      it_behaves_like(
        'a mail with subject and content',
        'You have a reference from Scott Knowles',
        'request other' => 'You’ve selected 2 references to submit with your application already',
      )
    end
  end
end
