require 'rails_helper'

RSpec.describe DsiProfile do
  describe '#update_profile_from_dfe_sign_in' do
    let(:provider_user) { create(:provider_user, email_address: 'original_provider@email.address') }
    let(:email_address) { 'provider_user@email.address' }
    let(:dfe_user) do
      DfESignInUser.new(
        email_address:,
        dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
        first_name: provider_user.first_name,
        last_name: provider_user.last_name,
      )
    end

    context "local_user's email_address" do
      it 'is updated if uid is previously known' do
        result = described_class.update_profile_from_dfe_sign_in dfe_user:, local_user: provider_user

        expect(result).to be_truthy
        expect(provider_user.reload.email_address).to eq(email_address)
      end

      it 'is not updated if uid is not yet established' do
        provider_user.update(dfe_sign_in_uid: nil)

        expect {
          described_class.update_profile_from_dfe_sign_in dfe_user:, local_user: provider_user
        }.not_to change(provider_user, :email_address)
      end

      it 'is not updated if no email is provided' do
        dfe_user_no_email = DfESignInUser.new(
          email_address: '',
          dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
          first_name: nil,
          last_name: nil,
        )

        expect {
          described_class.update_profile_from_dfe_sign_in dfe_user: dfe_user_no_email, local_user: provider_user
        }.not_to change(provider_user, :email_address)
      end

      context 'the email is already used by another user' do
        it 'is not updated' do
          _other_provider_user = create(:provider_user, email_address: email_address)

          result = described_class.update_profile_from_dfe_sign_in(dfe_user: dfe_user, local_user: provider_user)

          expect(result).to be_falsey
          expect(provider_user.reload.email_address).not_to eq(email_address)
        end
      end
    end

    context 'local_user\'s profile fields' do
      it 'updates first_name if supplied' do
        dfe_user.first_name = 'New name'
        described_class.update_profile_from_dfe_sign_in dfe_user: dfe_user, local_user: provider_user
        expect(provider_user.first_name).to eq('New name')
        dfe_user.first_name = ' '
        described_class.update_profile_from_dfe_sign_in dfe_user: dfe_user, local_user: provider_user
        expect(provider_user.first_name).to eq('New name')
      end

      it 'updates last_name if supplied' do
        dfe_user.last_name = 'New name'
        described_class.update_profile_from_dfe_sign_in dfe_user: dfe_user, local_user: provider_user
        expect(provider_user.last_name).to eq('New name')
        dfe_user.last_name = ' '
        described_class.update_profile_from_dfe_sign_in dfe_user: dfe_user, local_user: provider_user
        expect(provider_user.last_name).to eq('New name')
      end
    end
  end
end
