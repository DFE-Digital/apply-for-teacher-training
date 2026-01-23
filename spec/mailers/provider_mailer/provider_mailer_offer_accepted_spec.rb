require 'rails_helper'

RSpec.describe ProviderMailer do
  include TestHelpers::MailerSetupHelper

  describe '.offer_accepted' do
    let(:email) { described_class.offer_accepted(provider_user, application_choices.first) }
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:application_choices) do
      [build_stubbed(:application_choice,
                     :awaiting_provider_decision,
                     course_option:,
                     current_course_option:)]
    end
    let(:current_course_option) { course_option }
    let(:course_option) { build_stubbed(:course_option, course:, site: build_stubbed(:site, provider:)) }
    let(:course) { build_stubbed(:course, provider:, name: 'Computer Science', code: '6IND') }
    let(:provider) { build_stubbed(:provider, code: 'ABC', user: provider_user) }

    before { application_form }

    it_behaves_like('a mail with subject and content',
                    'Fred Freddy accepted your offer for Computer Science - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'course name' => 'Computer Science',
                    'offer link' => /http:\/\/localhost:3000\/provider\/applications\/\d+\/offers/,
                    'notification settings' => 'You can change your email notification settings',
                    'footer' => 'Get help, report a problem or give feedback')

    context 'with an alternative course offer' do
      let(:alternative_course) { build_stubbed(:course, provider:, name: 'Welding', code: '9ABC') }
      let(:current_course_option) { build_stubbed(:course_option, course: alternative_course) }

      it_behaves_like('a mail with subject and content',
                      'Fred Freddy accepted your offer for Welding - manage teacher training applications',
                      'provider name' => 'Dear Johny English',
                      'course name' => 'Welding',
                      'offer link' => /http:\/\/localhost:3000\/provider\/applications\/\d+\/offers/,
                      'notification settings' => 'You can change your email notification settings',
                      'footer' => 'Get help, report a problem or give feedback')
    end
  end
end
