require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.conditions_statuses_changed' do
    let(:met_conditions) { [build_stubbed(:text_condition, description: 'Do a cool trick')] }
    let(:pending_conditions) { [build_stubbed(:text_condition, description: 'Go to the moon')] }
    let(:previously_met_conditions) { [build_stubbed(:text_condition, description: 'Evidence of degree')] }
    let(:email) do
      described_class.conditions_statuses_changed(
        application_form.application_choices.first,
        met_conditions,
        pending_conditions,
        previously_met_conditions,
      )
    end
    let(:application_choices) do
      [build_stubbed(:application_choice, status: 'pending_conditions', course_option:, current_course_option: course_option)]
    end

    it_behaves_like(
      'a mail with subject and content',
      'Arithmetic College has updated the status of your conditions for Mathematics (M101)',
      'greeting' => 'Dear Fred',
      'met_condition_text' => 'They’ve marked the following condition as met:',
      'met_conditions' => 'Do a cool trick',
      'pending_condition_text' => 'They’ve marked the following condition as pending:',
      'pending_conditions' => 'Go to the moon',
      'previously_met_condition_text' => 'The following condition still needs to be met:',
      'previously_met_conditions' => 'Evidence of degree',
    )
  end
end
