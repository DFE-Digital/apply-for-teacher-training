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

  describe '.get_user_from_token!' do
    it 'gets the user for the passed token' do
      user = create(:support_user)
      create(:authentication_token,
             user: user,
             hashed_token: 'known_token',
             created_at: Time.zone.now)

      allow(MagicLinkToken).to receive(:from_raw).and_return('known_token')
      returned_user = SupportInterface::MagicLinkAuthentication.get_user_from_token!(token: 'known_token')

      expect(returned_user).to eq user
    end

    context 'when the token has expired' do
      it 'returns a falsey value' do
        user = create(:support_user)
        create(:authentication_token,
               user: user,
               hashed_token: 'known_token',
               created_at: (SupportInterface::MagicLinkAuthentication::TOKEN_DURATION + 1.second).ago)

        allow(MagicLinkToken).to receive(:from_raw).and_return('known_token')

        expect(SupportInterface::MagicLinkAuthentication.get_user_from_token!(token: 'known_token')).to be(false)
      end
    end
  end
end
