require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.reinstated_offer' do
    let(:application_choices) { [offer] }
    let(:email) do
      described_class.reinstated_offer(
        application_form.application_choices.first,
      )
    end

    context 'with conditions' do
      let(:offer) do
        build_stubbed(:application_choice, :offered,
                      application_form: build(:application_form, first_name: 'Fred', candidate:),
                      sent_to_provider_at: Time.zone.today,
                      offer: build_stubbed(:offer, conditions: [build_stubbed(:text_condition, description: 'Be cool')]),
                      course_option:)
      end

      it_behaves_like(
        'a mail with subject and content',
        'Your deferred offer to study Mathematics (M101) has been confirmed by Arithmetic College',
        'greeting' => 'Dear Fred',
        'details' => 'Arithmetic College has confirmed your deferred offer to study',
        'pending condition text' => 'You still need to meet the following condition',
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
        'Your deferred offer to study Mathematics (M101) has been confirmed by Arithmetic College',
        'heading' => 'Dear Fred',
        'provider name' => 'Arithmetic College has confirmed your deferred offer to study',
        'name and code for course' => 'Mathematics (M101)',
        'course starts text' => 'The course starts',
      )

      it 'does not refer to conditions' do
        expect(email.body).not_to include('condition')
      end
    end
  end
end
