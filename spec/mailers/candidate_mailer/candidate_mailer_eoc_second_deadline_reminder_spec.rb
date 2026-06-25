require 'rails_helper'

RSpec.describe CandidateMailer do
  include TestHelpers::MailerSetupHelper

  describe '.eoc_second_deadline_reminder', time: mid_cycle do
    let(:email) { described_class.eoc_second_deadline_reminder(application_form) }
    let(:timetable) { application_form.recruitment_cycle_timetable }
    let(:next_timetable) { timetable.relative_next_timetable }

    it_behaves_like(
      'a mail with subject and content',
      "Submit your teacher training application before #{I18n.l(current_timetable.apply_deadline_at.to_date, format: :no_year)}",
      'heading' => 'Dear Fred',
      'submit' => 'Submit your application for teacher training',
      'when ready' => 'when you’re ready.',
      'courses fill up' => 'Courses fill up quickly and may close early. Courses that offer visa sponsorship may have already closed.',
      'realistic job preview heading' => 'Gain insights into life as a teacher',
      'realistic job preview' => 'Try the realistic job preview tool',
      'realistic job preview link' => /https:\/\/platform\.teachersuccess\.co\.uk\/p\/.*\?id=\w{64}&utm_source/,
      'contact us' => 'Contact us',
      'contact details' => 'Call 0800 389 2500 or [chat online](https://getintoteaching.education.gov.uk/help-and-support) (Monday to Friday, 8:30am to 5:30pm UK time except on [bank holidays](https://www.gov.uk/bank-holidays))',
    )

    it_behaves_like 'an email with unsubscribe option'

    it 'renders the correct dates' do
      expect(email.body).to include("The deadline to apply to courses starting by the end of September #{timetable.recruitment_cycle_year} is #{application_form.apply_deadline_at.to_fs(:govuk_date_time_time_first)}.")
    end

    it 'renders not ready content' do
      expect(email.body).to include('If you’re not ready to submit your application')
      expect(email.body).to include('If you’re not ready to apply now, you can continue preparing your application.')
      expect(email.body).to include("From #{next_timetable.apply_opens_at.to_fs(:govuk_date)} you’ll be able to apply for courses starting in the #{next_timetable.academic_year_range_name} academic year.")
    end

    it 'renders get help with your application' do
      expect(email.body).to include('Get help with your application')
      expect(email.body).to include(
        'Learn more about [what to include in your application](https://getintoteaching.education.gov.uk/how-to-apply-for-teacher-training/teacher-training-application) on the Get Into Teaching website.',
      )
      expect(email.body).to include(
        'You can also [get a teacher training adviser](https://getintoteaching.education.gov.uk/teacher-training-advisers) for free, one-to-one support to help you write a strong application.',
      )
    end
  end

  describe 'tailored teacher training adviser text for "assigned" adviser status' do
    let(:application_form_with_adviser_eligibility) { create(:application_form_eligible_for_adviser, adviser_status: 'assigned') }

    subject(:email) { described_class.eoc_second_deadline_reminder(application_form_with_adviser_eligibility) }

    it 'refers to existing adviser' do
      expect(email.body).to have_text 'You can also contact your teacher training adviser for support with writing your application.'
    end
  end
end
