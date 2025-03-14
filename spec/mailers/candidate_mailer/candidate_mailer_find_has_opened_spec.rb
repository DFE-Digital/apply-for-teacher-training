require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.find_has_opened', time: after_find_opens do
    let(:email) { described_class.find_has_opened(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      'Find your teacher training course now',
      'greeting' => 'Dear Fred',
      'academic_year' => RecruitmentCycleTimetable.current_academic_year_range_name.to_s,
      'details' => 'Find your courses',
      'realistic job preview heading' => 'Gain insights into life as a teacher',
      'realistic job preview' => 'Try the realistic job preview tool',
      'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
    )

    it_behaves_like 'an email with unsubscribe option'
  end
end
