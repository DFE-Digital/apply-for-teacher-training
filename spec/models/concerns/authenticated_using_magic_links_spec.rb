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

      token = Timecop.travel(1.day.ago) do
        user.create_magic_link_token!
      end

      expect(ProviderUser.authenticate!(token)).to be_falsey
    end
  end
end
