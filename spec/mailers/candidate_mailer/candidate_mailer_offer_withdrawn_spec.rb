require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.offer_withdrawn' do
    let(:email) { described_class.offer_withdrawn(application_form.application_choices.first) }
    let(:candidate) { create(:candidate) }
    let(:application_form) do
      build_stubbed(:application_form, first_name: 'Fred',
                                       candidate:,
                                       recruitment_cycle_year:,
                                       application_choices:)
    end

    let(:application_choices) do
      [build_stubbed(
        :application_choice,
        status: 'offer_withdrawn',
        offer_withdrawal_reason: 'You lied to us about secretly being Spiderman',
        course_option:,
        current_course_option: course_option,
      )]
    end

    context 'between cycles, before find opens', time: after_apply_deadline(2024) do
      let(:recruitment_cycle_year) { 2024 }

      it_behaves_like(
        'a mail with subject and content',
        'Offer withdrawn by Arithmetic College',
        'still interested' => 'You can apply again for courses starting in the 2025 to 2026 academic year.',
        'when to apply again' => 'submit from 9am UK time on 8 October 2024',
      )
    end

    context 'between cycles, after find opens, before apply reopens', time: after_find_opens(2025) do
      let(:recruitment_cycle_year) { 2025 }

      it_behaves_like(
        'a mail with subject and content',
        'Offer withdrawn by Arithmetic College',
        'still interested' => 'You can apply again for courses starting in the 2025 to 2026 academic year.',
        'when to apply again' => 'submit from 9am UK time on 8 October 2024',
      )
    end

    context 'mid cycle', time: mid_cycle do
      let(:recruitment_cycle_year) { current_year }

      it_behaves_like(
        'a mail with subject and content',
        'Offer withdrawn by Arithmetic College',
        'greeting' => 'Dear Fred',
        'still interested' => 'If now’s the right time for you, you can still apply for teacher training again this year.',
        'offer details' => 'Arithmetic College has withdrawn their offer for you to study Mathematics (M101)',
        'withdrawal reason' => 'You lied to us about secretly being Spiderman',
        'realistic job preview' => 'Try the realistic job preview tool',
        'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
      )

      context 'with a course recommendation url' do
        let(:email) { described_class.offer_withdrawn(application_form.application_choices.first, 'https://www.find-postgraduate-teacher-training.service.gov.uk/results') }

        it_behaves_like(
          'a mail with subject and content',
          'Offer withdrawn by Arithmetic College',
          'greeting' => 'Dear Fred',
          'still interested' => 'If now’s the right time for you, you can still apply for teacher training again this year.',
          'offer details' => 'Arithmetic College has withdrawn their offer for you to study Mathematics (M101)',
          'withdrawal reason' => 'You lied to us about secretly being Spiderman',
          'realistic job preview' => 'Try the realistic job preview tool',
          'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
          'course recommendation' => 'Based on the details in your previous application, you could be suitable for other teacher training courses.',
          'course recommendation link' => 'https://www.find-postgraduate-teacher-training.service.gov.uk/results',
        )
      end
    end
  end
end
