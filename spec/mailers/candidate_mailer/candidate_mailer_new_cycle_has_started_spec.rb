require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.new_cycle_has_started', time: mid_cycle do
    let(:email) { described_class.new_cycle_has_started(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      "Apply for teacher training starting in the #{current_timetable.academic_year_range_name} academic year",
      'greeting' => 'Dear Fred',
      'academic_year' => "You can now apply for teacher training courses that start in the #{current_timetable.academic_year_range_name} academic year.",
      'details' => 'Courses can fill up quickly, so apply as soon as you are ready.',
    )

    it_behaves_like 'an email with unsubscribe option'
  end
end
