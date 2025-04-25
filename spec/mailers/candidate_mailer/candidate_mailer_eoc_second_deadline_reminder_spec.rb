require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.eoc_second_deadline_reminder', time: mid_cycle do
    let(:email) { described_class.eoc_second_deadline_reminder(application_form) }

    it_behaves_like(
      'a mail with subject and content',
      "Submit your teacher training application before #{I18n.l(current_timetable.apply_deadline_at.to_date, format: :no_year)}",
      'heading' => 'Dear Fred',
      'cycle_details' => "you’ll be able to apply for courses starting in the #{current_timetable.academic_year_range_name} academic year.",
      'details' => "You must submit your application by #{I18n.l(current_timetable.apply_deadline_at.to_date, format: :no_year)} if you want to start teacher training this year.",
      'realistic job preview heading' => 'Gain insights into life as a teacher',
      'realistic job preview' => 'Try the realistic job preview tool',
      'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
    )

    it_behaves_like 'an email with unsubscribe option'

    it 'renders adviser sign up text if not already assigned' do
      expect(email.body).to include('Need help writing a strong application? You can [get a teacher training adviser]')
    end
  end

  describe 'tailored teacher training adviser text for "assigned" adviser status' do
    let(:application_form_with_adviser_eligibility) { create(:application_form_eligible_for_adviser, adviser_status: 'assigned') }

    subject(:email) { described_class.eoc_second_deadline_reminder(application_form_with_adviser_eligibility) }

    it 'refers to existing adviser' do
      expect(email.body).to have_content 'Need help writing a strong application? You can get in touch with your teacher training adviser for one-to-one support.'
    end
  end
end
