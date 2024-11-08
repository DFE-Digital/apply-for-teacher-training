require 'rails_helper'

RSpec.describe ProviderMailer do
  describe '.fallback_sign_in_email' do
    let(:provider_user) { build_stubbed(:provider_user, first_name: 'Johny', last_name: 'English') }
    let(:email) { described_class.fallback_sign_in_email(provider_user, :token) }

    it_behaves_like('a mail with subject and content',
                    'Sign in - manage teacher training applications',
                    'provider name' => 'Dear Johny English',
                    'content' => 'You requested a link to sign in because DfE Sign-in is unavailable.',
                    'link to sign in' => 'http://localhost:3000/provider/sign-in-by-email?token=token',
                    'footer' => 'Get help, report a problem or give feedback')
  end
end
