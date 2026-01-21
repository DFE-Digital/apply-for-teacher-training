require 'rails_helper'

RSpec.describe DsiProfile do
  include DfESignInHelpers

  describe '#update_profile_from_omniauth_payload' do
    let(:provider_user) { create(:provider_user, email_address: 'original_provider@email.address') }
    let(:email_address) { 'provider_user@email.address' }
    let(:omniauth_payload) {
      fake_dfe_sign_in_auth_hash(
        email_address:,
        dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
        first_name: provider_user.first_name,
        last_name: provider_user.last_name,
      )
    }

    context "local_user's email_address" do
      it 'is updated if uid is previously known' do
        result = described_class.update_profile_from_omniauth_payload(
          omniauth_payload:,
          local_user: provider_user,
        )

        expect(result).to be_truthy
        expect(provider_user.reload.email_address).to eq(email_address)
      end

      it 'is not updated if uid is not yet established' do
        provider_user.update(dfe_sign_in_uid: nil)

        expect {
          described_class.update_profile_from_omniauth_payload(omniauth_payload:, local_user: provider_user)
        }.not_to change(provider_user, :email_address)
      end

      context 'no email' do
        let(:omniauth_payload) {
          fake_dfe_sign_in_auth_hash(
            email_address: '',
            dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
            first_name: nil,
            last_name: nil,
          )
        }

        it 'is not updated if no email is provided' do
          expect {
            described_class.update_profile_from_omniauth_payload(omniauth_payload:, local_user: provider_user)
          }.not_to change(provider_user, :email_address)
        end
      end

      context 'the email is already used by another user' do
        it 'is not updated' do
          _other_provider_user = create(:provider_user, email_address: email_address)

          result = described_class.update_profile_from_omniauth_payload(omniauth_payload:, local_user: provider_user)

          expect(result).to be_falsey
          expect(provider_user.reload.email_address).not_to eq(email_address)
        end
      end
    end

    context 'local_user\'s profile fields' do
      it 'updates first_name if supplied' do
        omniauth_payload['info']['first_name'] = 'New name'
        described_class.update_profile_from_omniauth_payload(
          omniauth_payload:,
          local_user: provider_user,
        )
        expect(provider_user.first_name).to eq('New name')
        omniauth_payload['info']['first_name'] = ' '
        described_class.update_profile_from_omniauth_payload(
          omniauth_payload:,
          local_user: provider_user,
        )
        expect(provider_user.first_name).to eq('New name')
      end

      it 'updates last_name if supplied' do
        omniauth_payload['info']['last_name'] = 'New name'
        described_class.update_profile_from_omniauth_payload(
          omniauth_payload:,
          local_user: provider_user,
        )
        expect(provider_user.last_name).to eq('New name')
        omniauth_payload['info']['last_name'] = ' '
        described_class.update_profile_from_omniauth_payload(
          omniauth_payload:,
          local_user: provider_user,
        )
        expect(provider_user.last_name).to eq('New name')
      end
    end
  end
end
