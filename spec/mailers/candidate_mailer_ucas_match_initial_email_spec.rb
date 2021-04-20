require 'rails_helper'

RSpec.describe CandidateMailer, type: :mailer do
  subject(:mailer) { described_class }

  around do |example|
    Timecop.freeze do
      example.run
    end
  end

  describe '.ucas_match_initial_email_duplicate_applications' do
    let(:email) { mailer.ucas_match_initial_email_duplicate_applications(application_form.application_choices.first) }
    let(:application_form) { build_stubbed(:application_form, first_name: 'Jane', application_choices: [application_choice]) }
    let(:provider) { build_stubbed(:provider, name: 'Coventry University') }
    let(:course_option) { build_stubbed(:course_option, course: build_stubbed(:course, name: 'Physics', code: '3PH5', provider: provider)) }
    let(:application_choice) { build_stubbed(:application_choice, course_option: course_option) }

    it_behaves_like(
      'a mail with subject and content',
      "Withdraw your duplicate application by #{10.business_days.from_now.to_s(:govuk_date)}",
      'heading' => 'Dear Jane',
      'course' => 'Physics (3PH5)',
      'provider' => 'Coventry University',
      'withdraw by date' => 10.business_days.from_now.to_s(:govuk_date),
    )
  end

  describe '.ucas_match_initial_email_multiple_acceptances' do
    let(:email) { mailer.ucas_match_initial_email_multiple_acceptances(candidate) }
    let(:candidate) { create(:candidate, application_forms: [application_form]) }
    let(:application_form) { create(:application_form, :minimum_info, first_name: 'Jane') }

    it_behaves_like(
      'a mail with subject and content',
      "Withdraw from one of your offers by #{10.business_days.from_now.to_s(:govuk_date)}",
      'heading' => 'Dear Jane',
      'withdrawal day' => 10.business_days.from_now.to_s(:govuk_date),
    )
  end
end
