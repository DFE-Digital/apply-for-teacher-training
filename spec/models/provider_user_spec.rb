require 'rails_helper'

RSpec.describe ProviderUser, type: :model do
  describe '#downcase_email_address' do
    it 'saves email_address in lower case' do
      provider_user = create :provider_user, email_address: 'Bob.Roberts@example.com'
      expect(provider_user.reload.email_address).to eq 'bob.roberts@example.com'
    end
  end

  describe '.onboard!' do
    it 'sets the DfE Sign-in ID on an existing user' do
      provider_user = create :provider_user, dfe_sign_in_uid: nil
      dsi_user = DfESignInUser.new(
        email_address: provider_user.email_address,
        dfe_sign_in_uid: 'ABC123',
      )
      ProviderUser.onboard!(dsi_user)
      expect(provider_user.reload.dfe_sign_in_uid).to eq 'ABC123'
    end

    it 'sets the DfE Sign-in ID on an existing user with a mixed case DfE Sign-in email' do
      provider_user = create :provider_user, dfe_sign_in_uid: nil, email_address: 'bob@example.com'
      dsi_user = DfESignInUser.new(
        email_address: 'BoB@example.com',
        dfe_sign_in_uid: 'ABC123',
      )
      ProviderUser.onboard!(dsi_user)
      expect(provider_user.reload.dfe_sign_in_uid).to eq 'ABC123'
    end
  end
end
