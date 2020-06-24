require 'rails_helper'

RSpec.describe 'ProviderRelationshipPermissions setup', type: :request do
  let(:provider) { create(:provider, :with_signed_agreement) }
  let(:provider_user) { create(:provider_user, providers: [provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

  before do
    FeatureFlag.activate('enforce_provider_to_provider_permissions')

    allow(DfESignInUser).to receive(:load_from_session)
      .and_return(
        DfESignInUser.new(
          email_address: provider_user.email_address,
          dfe_sign_in_uid: provider_user.dfe_sign_in_uid,
          first_name: provider_user.first_name,
          last_name: provider_user.last_name,
        ),
      )
  end

  describe 'redirecting when permissions need setup' do
    context 'when the user has permissions to manage the provider' do
      before do
        create(:training_provider_permissions, training_provider: provider, setup_at: nil)
        provider_user.provider_permissions.find_by(provider: provider).update(manage_organisations: true)
      end

      it 'redirects to setup' do
        get provider_interface_applications_path

        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(provider_interface_provider_relationship_permissions_setup_url)
      end
    end

    context 'when the user does not have permissions to manage the provider' do
      before do
        create(:training_provider_permissions, ratifying_provider: provider, setup_at: nil)
        provider_user.provider_permissions.find_by(provider: provider).update(manage_organisations: true)
      end

      it 'does not redirect to setup' do
        get provider_interface_applications_path

        expect(response.status).to eq(200)
      end
    end
  end

  describe 'when no relevant permissions need setup' do
    before do
      create(:training_provider_permissions, setup_at: nil)
      create(:training_provider_permissions, ratifying_provider: provider, setup_at: Time.current)
      provider_user.provider_permissions.find_by(provider: provider).update(manage_organisations: true)
    end

    it 'does not redirect' do
      get provider_interface_applications_path

      expect(response.status).to eq(200)
    end
  end
end
