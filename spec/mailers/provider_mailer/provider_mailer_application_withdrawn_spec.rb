require 'rails_helper'

RSpec.describe ProviderMailer do
  include TestHelpers::MailerSetupHelper

  describe 'Send email when the application is manually withdrawn' do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:application_choices) do
      [build_stubbed(:application_choice,
                     :awaiting_provider_decision,
                     course_option:,
                     current_course_option:)]
    end
    let(:current_course_option) { course_option }
    let(:course_option) { build_stubbed(:course_option, course:) }
    let(:course) { build_stubbed(:course, provider:, name: 'Computer Science', code: '6IND') }
    let(:provider) { build_stubbed(:provider, code: 'ABC', user: provider_user) }
    let(:email) { described_class.application_withdrawn(provider_user, application_choices.first, number_of_cancelled_interviews) }
    let(:number_of_cancelled_interviews) { 0 }

    before { application_form }

    context 'without an alternative course offer' do
      it_behaves_like('a mail with subject and content',
                      'Fred Freddy withdrew their application - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'candidate name' => 'Fred Freddy',
                      'course name and code' => 'Computer Science (6IND)',
                      'link to application' => /http:\/\/localhost:3000\/provider\/applications\/\d+/,
                      'notification settings' => 'You can change your email notification settings',
                      'footer' => 'Get help, report a problem or give feedback')
    end

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider:, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course) }

      it_behaves_like('a mail with subject and content',
                      'Fred Freddy withdrew their application - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'course name and code' => 'Welding (9ABC)')
    end

    context 'when some interviews were cancelled' do
      let(:number_of_cancelled_interviews) { 2 }

      it_behaves_like('a mail with subject and content',
                      'Fred Freddy withdrew their application - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'candidate name' => 'Fred Freddy',
                      'course name and code' => 'Computer Science (6IND)',
                      'interviews_cancelled' => 'The upcoming interviews with them have been cancelled.')
    end
  end

  describe 'Send email when the application is automatically withdrawn after accepting an offer' do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:application_choices) do
      [build_stubbed(:application_choice,
                     :awaiting_provider_decision,
                     course_option:,
                     current_course_option:)]
    end
    let(:current_course_option) { course_option }
    let(:course_option) { build_stubbed(:course_option, course:) }
    let(:course) { build_stubbed(:course, provider:, name: 'Computer Science', code: '6IND') }
    let(:provider) { build_stubbed(:provider, code: 'ABC', user: provider_user) }
    let(:email) { described_class.application_auto_withdrawn_on_accept_offer(provider_user, application_choices.first) }

    before { application_form }

    context 'without an alternative course offer' do
      it_behaves_like('a mail with subject and content',
                      'Fred Freddy’s application has been automatically withdrawn - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'candidate name' => 'Fred',
                      'link to application' => /http:\/\/localhost:3000\/provider\/applications\/\d+/,
                      'notification settings' => 'You can change your email notification settings',
                      'footer' => 'Get help, report a problem or give feedback')
    end
  end
end
