require 'rails_helper'

RSpec.describe SupportInterface::MagicLinkAuthentication do
  describe '.send_token!' do
    it 'sets magic_link token' do
      user = create(:support_user)

      Timecop.freeze do
        expect {
          SupportInterface::MagicLinkAuthentication.send_token!(support_user: user)
        }.to change { user.authentication_tokens.first }.from(nil).to(AuthenticationToken)
      end
    end
  end
end
