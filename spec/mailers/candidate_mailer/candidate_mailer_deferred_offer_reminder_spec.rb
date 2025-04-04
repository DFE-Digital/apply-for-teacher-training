require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.deferred_offer_reminder', time: mid_cycle do
    let(:email) { described_class.deferred_offer_reminder(application_choices.first) }
    let(:application_choices) do
      [build_stubbed(:application_choice,
                     :offer_deferred,
                     course_option:,
                     current_course_option: course_option,
                     offer_deferred_at: Time.zone.local(current_year, 4, 15))]
    end

    before { application_form }

    it_behaves_like(
      'a mail with subject and content',
      'Reminder of your deferred offer',
      'heading' => 'Dear Fred',
      'when offer deferred' => "On 15 April #{current_year}",
      'provider and course name' => 'Arithmetic College deferred your offer to study Mathematics (M101)',
    )
  end
end
