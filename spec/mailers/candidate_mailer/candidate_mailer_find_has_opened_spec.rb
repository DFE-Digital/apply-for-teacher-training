require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.find_has_opened', time: after_find_opens do
    let(:email) { described_class.find_has_opened(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Find your teacher training course now',
      'greeting' => 'Dear Fred',
      'academic_year' => current_timetable.academic_year_range_name.to_s,
      'details' => 'Find your courses',
      'life as a teacher heading' => 'Gain insights into life as a teacher',
    )

    it_behaves_like 'an email with unsubscribe option'
  end
end
