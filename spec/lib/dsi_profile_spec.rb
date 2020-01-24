require 'rails_helper'

RSpec.describe DsiProfile do
  describe '#update_profile_from_dfe_sign_in' do
    let(:provider_user) { create(:provider_user) }
    let(:support_user) { create(:provider_user) }
    let(:dfe_user) {
      DfESignInUser.new(
        email_address: 'new+email@example.com',
        dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
        first_name: provider_user.first_name,
        last_name: provider_user.last_name,
      )
    }

    context 'local_user\'s email_address' do
      it 'is updated if uid is previously known' do
        DsiProfile.update_profile_from_dfe_sign_in dfe_user: dfe_user, local_user: provider_user
        expect(provider_user.email_address).to eq('new+email@example.com')
      end

      it 'is not updated if uid is not yet established' do
        provider_user.update(dfe_sign_in_uid: nil)
        DsiProfile.update_profile_from_dfe_sign_in dfe_user: dfe_user, local_user: provider_user
        expect(provider_user.email_address).to eq(provider_user.email_address)
      end

      it 'is not updated if no email is provided' do
        dfe_user_no_email = DfESignInUser.new(
          email_address: '',
          dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
          first_name: nil,
          last_name: nil,
        )
        DsiProfile.update_profile_from_dfe_sign_in dfe_user: dfe_user_no_email, local_user: provider_user
        expect(provider_user.email_address).to eq(provider_user.email_address)
      end
    end

    context 'local_user\'s profile fields' do
      it 'updates first_name if supplied' do
        dfe_user.first_name = 'New name'
        DsiProfile.update_profile_from_dfe_sign_in dfe_user: dfe_user, local_user: provider_user
        expect(provider_user.first_name).to eq('New name')
        dfe_user.first_name = ' '
        DsiProfile.update_profile_from_dfe_sign_in dfe_user: dfe_user, local_user: provider_user
        expect(provider_user.first_name).to eq('New name')
      end

      it 'updates last_name if supplied' do
        dfe_user.last_name = 'New name'
        DsiProfile.update_profile_from_dfe_sign_in dfe_user: dfe_user, local_user: provider_user
        expect(provider_user.last_name).to eq('New name')
        dfe_user.last_name = ' '
        DsiProfile.update_profile_from_dfe_sign_in dfe_user: dfe_user, local_user: provider_user
        expect(provider_user.last_name).to eq('New name')
      end
    end
  end
end
