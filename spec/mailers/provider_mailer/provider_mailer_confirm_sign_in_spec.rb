require 'rails_helper'

RSpec.describe ProviderMailer do
  describe 'confirm_sign_in' do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:email) { described_class.confirm_sign_in(provider_user, timestamp:) }
    let(:timestamp) { Date.parse('22-02-2022').midnight }

    it_behaves_like('a mail with subject and content',
                    'Sign in from new device detected - manage teacher training applications',
                    'salutation' => 'Dear Johny',
                    'date' => '22 February 2022',
                    'time' => '12am',
                    'footer' => 'Get help, report a problem or give feedback')
  end
end
