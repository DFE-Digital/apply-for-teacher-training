require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  around do |example|
    Timecop.freeze(Date.new(2020, 11, 23)) do
      example.run
    end
  end

  subject(:mailer) { described_class }

  describe '.ucas_match_reminder_email_duplicate_applications' do
    let(:email) { mailer.ucas_match_reminder_email_duplicate_applications(application_form.application_choices.first, ucas_match) }
    let(:ucas_match) { build_stubbed(:ucas_match, candidate_last_contacted_at: Time.zone.local(2020, 11, 16)) }
    let(:application_form) { build_stubbed(:application_form, first_name: 'Jane', application_choices: [application_choice]) }
    let(:provider) { build_stubbed(:provider, name: 'City University') }
    let(:course_option) { build_stubbed(:course_option, course: course) }
    let(:course) { build_stubbed(:course, name: 'Physics', code: '3PH5', provider: provider) }
    let(:application_choice) { build_stubbed(:application_choice, course_option: course_option) }

    it_behaves_like(
      'a mail with subject and content',
      'Withdraw your duplicate application by 30 November 2020',
      'heading' => 'Dear Jane',
      'course name and code' => 'Physics (3PH5)',
      'provider' => 'City University',
      'withdraw by date' => '30 November 2020',
    )
  end

  describe '.ucas_match_reminder_email_multiple_acceptances' do
    let(:email) { mailer.ucas_match_reminder_email_multiple_acceptances(candidate.ucas_match) }
    let(:ucas_match) { create(:ucas_match, candidate_last_contacted_at: Time.zone.local(2020, 11, 16)) }
    let(:candidate) { create(:candidate, ucas_match: ucas_match, application_forms: [application_form]) }
    let(:application_form) { create(:application_form, first_name: 'Jane') }

    it_behaves_like(
      'a mail with subject and content',
      'Withdraw from one of your offers by 30 November 2020',
      'heading' => 'Dear Jane',
      'withdraw by date' => '30 November 2020',
    )
  end
end
