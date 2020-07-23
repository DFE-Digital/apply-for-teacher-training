require 'rails_helper'

RSpec.describe ProviderInterface::MagicLinkAuthentication do
  describe '.send_token!' do
    it 'sets magic_link token and a magic_link_token_sent_at on the provider_user' do
      user = create(:provider_user)

      Timecop.freeze do
        expect {
          ProviderInterface::MagicLinkAuthentication.send_token!(provider_user: user)
        }.to change { user.authentication_tokens.first }.from(nil).to(AuthenticationToken)
      end
    end
  end
end
