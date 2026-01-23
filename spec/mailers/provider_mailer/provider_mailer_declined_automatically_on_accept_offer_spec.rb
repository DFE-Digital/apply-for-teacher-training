require 'rails_helper'

RSpec.describe ProviderMailer do
  include TestHelpers::MailerSetupHelper

  let(:email) { described_class.declined_automatically_on_accept_offer(provider_user, application_choices.first) }

  describe '.declined_automatically_on_accept_offer' do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:application_choices) { [build_stubbed(:application_choice, :awaiting_provider_decision)] }

    before { application_form }

    it_behaves_like('a mail with subject and content',
                    'Fred Freddy’s offer has been automatically declined - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'candidate name' => 'Fred Freddy ',
                    'offer link' => /http:\/\/localhost:3000\/provider\/applications\/\d+\/offers/,
                    'notification settings' => 'You can change your email notification settings',
                    'footer' => 'Get help, report a problem or give feedback')
  end
end
