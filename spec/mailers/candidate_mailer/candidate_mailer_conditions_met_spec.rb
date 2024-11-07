require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.conditions_met with pending SKE conditions' do
    let(:text_conditions) { [build_stubbed(:text_condition, status: :met)] }
    let(:ske_conditions) { [build_stubbed(:ske_condition, status: :pending)] }
    let(:email) do
      described_class.conditions_met(application_form.application_choices.first)
    end
    let(:application_form) { build_stubbed(:application_form, first_name: 'Fred', candidate:, application_choices:) }
    let(:application_choices) do
      [
        build_stubbed(
          :application_choice,
          status: 'recruited',
          course_option:,
          current_course_option: course_option,
          offer: build_stubbed(:offer, text_conditions:, ske_conditions:),
        ),
      ]
    end

    before do
      application_choices.first.provider.provider_type = :scitt
      application_choices.first.course.start_date = 2.months.from_now
    end

    it_behaves_like(
      'a mail with subject and content',
      'You have met your conditions to study Mathematics (M101) at Arithmetic College',
      'greeting' => 'Dear Fred',
      'met_conditions_text' => 'Arithmetic College has confirmed that you have met the conditions of your offer.',
    )

    context 'with a pending SKE condition' do
      before do
        application_choices.first.offer.conditions.each { |condition| condition.status = :met }
      end

      it_behaves_like(
        'a mail with subject and content',
        'You have met your conditions to study Mathematics (M101) at Arithmetic College',
        'greeting' => 'Dear Fred',
        'met_conditions_text' => 'Arithmetic College has confirmed that you have met the conditions of your offer.',
        'pending_ske_conditions_text' => 'Remember to complete your subject knowledge enhancement (SKE) course to meet the conditions of this offer.',
      )
    end
  end
end
