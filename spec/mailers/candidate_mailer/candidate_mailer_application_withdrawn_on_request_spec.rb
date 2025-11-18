require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.application_withdrawn_on_request' do
    let(:email) { described_class.application_withdrawn_on_request(application_form.application_choices.first) }

    context 'mid cycle', time: mid_cycle do
      it_behaves_like(
        'a mail with subject and content',
        'Update on your application',
        'greeting' => 'Hello Fred',
        'details' => 'has withdrawn your application for',
        'still interested' => 'If now’s the right time for you, you can still apply for up to 3 more courses this year.',
        'content' => 'If now’s the right time for you, you can still apply for up to 3 more courses this year.',
        'realistic job preview' => 'Try the realistic job preview tool',
        'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
      )

      context 'with a course recommendation url' do
        let(:email) { described_class.application_withdrawn_on_request(application_form.application_choices.first, 'https://www.find-postgraduate-teacher-training.service.gov.uk/results') }

        it_behaves_like(
          'a mail with subject and content',
          'Update on your application',
          'greeting' => 'Hello Fred',
          'details' => 'has withdrawn your application for',
          'still interested' => 'If now’s the right time for you, you can still apply for up to 3 more courses this year.',
          'content' => 'If now’s the right time for you, you can still apply for up to 3 more courses this year.',
          'realistic job preview' => 'Try the realistic job preview tool',
          'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
          'course recommendation' => 'Based on the details in your previous application, you could be suitable for other teacher training courses.',
          'course recommendation link' => 'https://www.find-postgraduate-teacher-training.service.gov.uk/results',
        )
      end
    end

    context 'between cycles, before find reopens', time: after_apply_deadline(2024) do
      it_behaves_like(
        'a mail with subject and content',
        'Update on your application',
        'greeting' => 'Hello Fred',
        'still interested' => 'You can apply again for courses starting in the 2025 to 2026 academic year.',
        'when to apply again' => 'submit from 9am UK time on 8 October 2024',
      )
    end

    context 'between cycles, before find reopens', time: after_find_opens(2025) do
      it_behaves_like(
        'a mail with subject and content',
        'Update on your application',
        'greeting' => 'Hello Fred',
        'still interested' => 'You can apply again for courses starting in the 2025 to 2026 academic year.',
        'when to apply again' => 'submit from 9am UK time on 8 October 2024',
      )
    end
  end
end
