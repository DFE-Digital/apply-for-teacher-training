require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.deferred_offer_new_details' do
    let(:application_choices) { [offer] }
    let(:email) do
      described_class.deferred_offer_new_details(
        application_form.application_choices.first,
      )
    end

    context 'with conditions' do
      let(:email) do
        described_class.deferred_offer_new_details(
          application_form.application_choices.first,
          conditions_met: false,
        )
      end

      let(:offer) do
        build_stubbed(:application_choice, :offered,
                      application_form: build(:application_form, first_name: 'Fred', candidate:),
                      sent_to_provider_at: Time.zone.today,
                      offer: build_stubbed(:offer, conditions: [build_stubbed(:text_condition, description: 'Be cool')]),
                      course_option:)
      end

      it_behaves_like(
        'a mail with subject and content',
        'Your deferred offer to study Mathematics (M101) has been changed',
        'greeting' => 'Dear Fred',
        'details' => 'Sign in to your account to check the progress of your offer conditions.',
        'pending condition text' => 'If the offer is still suitable for you, you need to meet the following',
        'pending condition' => 'Be cool',
      )
    end

    context 'with an unconditional offer' do
      let(:offer) do
        build_stubbed(:application_choice, :offered,
                      application_form: build(:application_form, first_name: 'Fred', candidate:),
                      sent_to_provider_at: Time.zone.today,
                      offer: build_stubbed(:offer, conditions: []),
                      course_option:)
      end

      it 'does not refer to conditions' do
        expect(email.body).not_to include('condition')
      end
    end

    context 'with met conditions' do
      let(:offer) do
        build_stubbed(:application_choice, :offered,
                      application_form: build(:application_form, first_name: 'Fred', candidate:),
                      sent_to_provider_at: Time.zone.today,
                      offer: build_stubbed(:offer, conditions: [build_stubbed(:text_condition, status: :met, description: 'GCSE Maths grade 4 (C) or above, or equivalent')]),
                      course_option:)
      end

      it_behaves_like(
        'a mail with subject and content',
        'Your deferred offer to study Mathematics (M101) has been changed',
        'greeting' => 'Dear Fred',
        'details' => 'will let you know if they need further information before you start training',
        'name and code for course' => 'Mathematics (M101)',
        'course starts text' => 'The course starts',
      )

      it 'does not refer to conditions' do
        expect(email.body).not_to include('condition')
      end
    end
  end
end
