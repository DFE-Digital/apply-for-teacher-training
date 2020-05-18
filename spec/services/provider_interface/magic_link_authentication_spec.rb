require 'rails_helper'

RSpec.describe ProviderInterface::MagicLinkAuthentication do
  describe '.send_token!' do
    it 'sets magic_link token and a magic_link_token_sent_at on the provider_user' do
      user = create(:provider_user)

      Timecop.freeze do
        expect {
          ProviderInterface::MagicLinkAuthentication.send_token!(provider_user: user)
        }.to change { user.magic_link_token }.from(nil).to(String)
          .and change { user.magic_link_token_sent_at }.from(nil).to(Time.zone.now)
      end
    end
  end

  describe '.get_user_from_token!' do
    it 'gets the user for the passed token' do
      user = create(:provider_user,
                    magic_link_token: 'known_token',
                    magic_link_token_sent_at: Time.zone.now)

      allow(MagicLinkToken).to receive(:from_raw).and_return('known_token')
      returned_user = ProviderInterface::MagicLinkAuthentication.get_user_from_token!(token: 'known_token')

      expect(returned_user).to eq user
    end

    context 'when the token has expired' do
      it 'raises an ActiveRecord::RecordNotFound error' do
        create(:provider_user,
               magic_link_token: 'known_token',
               magic_link_token_sent_at: (ProviderInterface::MagicLinkAuthentication::TOKEN_DURATION + 1.second).ago)

        allow(MagicLinkToken).to receive(:from_raw).and_return('known_token')

        expect {
          ProviderInterface::MagicLinkAuthentication.get_user_from_token!(token: 'known_token')
        }.to raise_error(ActiveRecord::RecordNotFound)
      end
    end
  end
end
