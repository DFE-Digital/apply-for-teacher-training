require 'rails_helper'

RSpec.describe ProviderMailer do
  include TestHelpers::MailerSetupHelper

  describe 'Send application submitted with safeguarding issues email' do
    let(:email) { described_class.application_submitted_with_safeguarding_issues(provider_user, application_choices.first) }
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:application_choices) do
      [build_stubbed(:application_choice,
                     :awaiting_provider_decision,
                     course_option:,
                     current_course_option: course_option)]
    end
    let(:course_option) { build_stubbed(:course_option, course:, site: build_stubbed(:site, provider:)) }
    let(:course) { build_stubbed(:course, provider:, name: 'Computer Science', code: '6IND') }
    let(:provider) { build_stubbed(:provider, code: 'ABC', user: provider_user) }

    before { application_form }

    context 'when a candidate submits an application' do
      it_behaves_like('a mail with subject and content',
                      'Safeguarding issues - Fred Freddy submitted an application for Computer Science - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'candidate name' => 'Fred',
                      'course name and code' => 'Computer Science (6IND)',
                      'safeguarding warning' => 'The application contains information about criminal convictions and professional misconduct.',
                      'link to application' => /http:\/\/localhost:3000\/provider\/applications\/\d+/,
                      'notification settings' => 'You can change your email notification settings',
                      'footer' => 'Get help, report a problem or give feedback')
    end
  end
end
