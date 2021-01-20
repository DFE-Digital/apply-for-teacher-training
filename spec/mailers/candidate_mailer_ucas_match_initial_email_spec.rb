require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  subject(:mailer) { described_class }

  around do |example|
    Timecop.freeze(Time.zone.local(2021, 1, 17)) do
      example.run
    end
  end

  let(:application_form) { build_stubbed(:application_form, first_name: 'Jane', application_choices: [application_choice]) }
  let(:provider) { build_stubbed(:provider, name: 'Coventry University') }
  let(:course_option) { build_stubbed(:course_option, course: build_stubbed(:course, name: 'Physics', code: '3PH5', provider: provider)) }
  let(:application_choice) { build_stubbed(:application_choice, course_option: course_option) }

  describe '.ucas_match_initial_email_duplicate_applications' do
    let(:email) { mailer.ucas_match_initial_email_duplicate_applications(application_form.application_choices.first) }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.ucas_match.duplicate_applications.subject', withdraw_by_date: '1 February 2021'),
      'heading' => 'Dear Jane',
      'course' => 'Physics (3PH5)',
      'provider' => 'Coventry University',
      'withdraw by date' => '1 February 2021',
    )
  end

  describe '.ucas_match_initial_email_multiple_acceptances' do
    let(:email) { mailer.ucas_match_initial_email_multiple_acceptances(candidate) }
    let(:candidate) { build_stubbed(:candidate, application_forms: [application_form]) }

    it_behaves_like(
      'a mail with subject and content',
      I18n.t!('candidate_mailer.ucas_match_initial_email.multiple_acceptances.subject'),
      'heading' => 'Dear Jane',
      'withdrawal day' => '1 February 2021',
    )
  end
end
