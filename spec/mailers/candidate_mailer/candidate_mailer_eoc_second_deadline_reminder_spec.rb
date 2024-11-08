require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.eoc_second_deadline_reminder' do
    let(:email) { described_class.eoc_second_deadline_reminder(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      "Submit your teacher training application before #{I18n.l(CycleTimetable.apply_deadline.to_date, format: :no_year)}",
      'heading' => 'Dear Fred',
      'cycle_details' => "you’ll be able to apply for courses starting in the #{RecruitmentCycle.cycle_name(RecruitmentCycle.next_year)} academic year.",
      'details' => "You must submit your application by #{I18n.l(CycleTimetable.apply_deadline.to_date, format: :no_year)} if you want to start teacher training this year.",
    )
  end
end
