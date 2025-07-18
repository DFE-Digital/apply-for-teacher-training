require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.decline_last_application_choice' do
    let(:application_form) { build_stubbed(:application_form, first_name: 'Fred') }
    let(:application_choices) { [build_stubbed(:application_choice, status: :declined, application_form:)] }
    let(:email) { described_class.decline_last_application_choice(application_choices.first) }

    context 'mid cycle', time: mid_cycle do
      it_behaves_like(
        'a mail with subject and content',
        'You have declined an offer: next steps',
        'greeting' => 'Hello Fred',
        'still interested' => 'If now’s the right time for you, you can still apply for teacher training again this year.',
        'content' => 'declined your offer to study',
        'realistic job preview' => 'Try the realistic job preview tool',
        'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
      )
      context 'with a course recommendation url' do
        let(:email) { described_class.decline_last_application_choice(application_choices.first, 'https://www.find-postgraduate-teacher-training.service.gov.uk/results') }

        it_behaves_like(
          'a mail with subject and content',
          'You have declined an offer: next steps',
          'greeting' => 'Hello Fred',
          'still interested' => 'If now’s the right time for you, you can still apply for teacher training again this year.',
          'content' => 'declined your offer to study',
          'realistic job preview' => 'Try the realistic job preview tool',
          'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
          'course recommendation' => 'Based on the details in your previous application, you could be suitable for other teacher training courses.',
          'course recommendation link' => 'https://www.find-postgraduate-teacher-training.service.gov.uk/results',
        )
      end
    end

    context 'between cycles, before find opens', time: after_apply_deadline(2024) do
      it_behaves_like(
        'a mail with subject and content',
        'You have declined an offer: next steps',
        'greeting' => 'Hello Fred',
        'still interested' => 'You can apply again for courses starting in the 2025 to 2026 academic year.',
        'when to apply again' => 'submit from 9am UK time on 8 October 2024',
      )
    end

    context 'between cycles, before find opens', time: after_find_opens(2025) do
      it_behaves_like(
        'a mail with subject and content',
        'You have declined an offer: next steps',
        'greeting' => 'Hello Fred',
        'still interested' => 'You can apply again for courses starting in the 2025 to 2026 academic year.',
        'when to apply again' => 'submit from 9am UK time on 8 October 2024',
      )
    end
  end
end
