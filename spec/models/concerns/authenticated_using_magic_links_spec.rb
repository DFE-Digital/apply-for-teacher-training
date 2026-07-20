require 'rails_helper'

RSpec.describe AuthenticatedUsingMagicLinks do
  describe '.authenticate!' do
    it 'returns the user if the token is valid, but only once' do
      user = create(:provider_user)

      token = user.create_magic_link_token!

      expect(ProviderUser.authenticate!(token)).to eql(user)
      expect(ProviderUser.authenticate!(token)).to be_falsey
    end

    it 'returns nil if the token does not exist' do
      expect(ProviderUser.authenticate!('ABCDEF')).to be_falsey
    end

    it 'returns nil if the token is expired' do
      user = create(:provider_user)

      token = travel_temporarily_to(1.day.ago) do
        user.create_magic_link_token!
      end

      expect(ProviderUser.authenticate!(token)).to be_falsey
    end
  end

  describe '#magic_link_recently_requested?' do
    context 'when a magic link is requested within 1 minute' do
      it 'returns an error' do
        user = create(:provider_user)
        user.create_magic_link_token!
        expect { user.create_magic_link_token! }.to raise_error(
          AuthenticatedUsingMagicLinks::MagicLinkTokenAlreadyRequestedError,
        )
      end
    end

    context 'when a magic link it requested over a minute apart' do
      it 'does not return an error' do
        user = create(:provider_user)
        user.create_magic_link_token!
        user.authentication_tokens.last.update!(created_at: 2.minutes.ago)
        expect { user.create_magic_link_token! }.not_to raise_error(
          AuthenticatedUsingMagicLinks::MagicLinkTokenAlreadyRequestedError,
        )
      end
    end
  end
end
