require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.withdraw_last_application_choice' do
    let(:recruitment_cycle_year) { current_year }
    let(:application_form_with_references) do
      create(:application_form, first_name: 'Fred',
                                recruitment_cycle_year: recruitment_cycle_year,
                                application_choices: application_choices,
                                application_references: [referee1, referee2])
    end
    let(:referee1) { create(:reference, name: 'Jenny', feedback_status: :feedback_requested) }
    let(:referee2) { create(:reference, name: 'Luke',  feedback_status: :feedback_requested) }
    let(:email) { described_class.withdraw_last_application_choice(application_form_with_references) }

    context 'when a candidate has 1 course choice that was withdrawn' do
      let(:application_choices) { [create(:application_choice, status: 'withdrawn')] }

      context 'mid cycle', time: mid_cycle do
        it_behaves_like(
          'a mail with subject and content',
          'You have withdrawn your application',
          'heading' => 'Hello Fred',
          'still interested' => 'If now’s the right time for you, you can still apply for teacher training again this year.',
          'application_withdrawn' => 'You have withdrawn your application',
          'realistic job preview' => 'Try the realistic job preview tool',
          'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
        )
      end

      context 'between cycles, before find opens', time: after_apply_deadline(2024) do
        it_behaves_like(
          'a mail with subject and content',
          'You have withdrawn your application',
          'heading' => 'Hello Fred',
          'still interested' => 'You can apply again for courses starting in the 2025 to 2026 academic year.',
          'when to apply again' => 'submit from 9am on 8 October 2024',
        )
      end

      context 'between cycles, before apply reopens', time: after_find_opens(2025) do
        it_behaves_like(
          'a mail with subject and content',
          'You have withdrawn your application',
          'heading' => 'Hello Fred',
          'still interested' => 'You can apply again for courses starting in the 2025 to 2026 academic year.',
          'when to apply again' => 'submit from 9am on 8 October 2024',
        )
      end
    end

    context 'when new reference flow is active' do
      let(:recruitment_cycle_year) { current_year }
      let(:application_choices) { [create(:application_choice, status: 'withdrawn')] }

      it_behaves_like(
        'a mail with subject and content',
        'You have withdrawn your application',
        'heading' => 'Hello Fred',
        'application_withdrawn' => 'You have withdrawn your application',
      )
    end

    context 'when a candidate has 2 or 3 offers that were withdrawn' do
      let(:application_choices) { [create(:application_choice, :withdrawn), create(:application_choice, :withdrawn)] }

      it_behaves_like(
        'a mail with subject and content',
        'You have withdrawn your applications',
        'application_withdrawn' => 'You have withdrawn your application',
      )
    end
  end
end
