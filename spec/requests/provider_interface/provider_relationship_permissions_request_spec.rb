require 'rails_helper'

RSpec.describe 'ProviderRelationshipPermissions', type: :request do
  let(:provider) { create(:provider, :with_signed_agreement) }
  let(:provider_user) { create(:provider_user, providers: [provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

  before do
    FeatureFlag.activate(:providers_can_manage_users_and_permissions)

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

  describe 'invalid provider relationship params' do
    context 'GET edit' do
      it 'responds with 404' do
        get provider_interface_edit_provider_relationship_permissions_path(
          ratifying_provider_id: 1,
          training_provider_id: 1,
        )

        expect(response.status).to eq(404)
      end
    end

    context 'PATCH update' do
      it 'responds with 404' do
        patch provider_interface_update_provider_relationship_permissions_path(
          ratifying_provider_id: 1,
          training_provider_id: 1,
        )

        expect(response.status).to eq(404)
      end
    end
  end

  describe 'with a provider relationship not associated with the current user' do
    let(:ratifying_provider) { create(:provider) }
    let(:training_provider) { create(:provider) }

    before do
      create(
        :provider_relationship_permissions,
        ratifying_provider: ratifying_provider,
        training_provider: training_provider,
      )
      provider_user.provider_permissions.update_all(manage_organisations: true)
    end

    context 'GET edit' do
      it 'responds with 403 Forbidden' do
        get provider_interface_edit_provider_relationship_permissions_path(
          ratifying_provider_id: ratifying_provider.id,
          training_provider_id: training_provider.id,
        )

        expect(response.status).to eq(403)
      end
    end

    describe 'PATCH update' do
      it 'responds with 403 Forbidden' do
        patch provider_interface_update_provider_relationship_permissions_path(
          ratifying_provider_id: ratifying_provider.id,
          training_provider_id: training_provider.id,
        )

        expect(response.status).to eq(403)
      end
    end
  end
end
