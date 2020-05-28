require 'rails_helper'

RSpec.describe 'ProviderRelationshipPermissions', type: :request do
  let(:provider) { create(:provider, :with_signed_agreement) }
  let(:provider_user) { create(:provider_user, providers: [provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

  before do
    FeatureFlag.activate('provider_add_provider_users')

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

  describe 'GET edit' do
    context 'with invalid provider relationship permissions params' do
      it 'responds with 404' do
        get provider_interface_edit_provider_relationship_permissions_path(
          ratifying_provider_id: 1,
          training_provider_id: 1,
        )

        expect(response.status).to eq(404)
      end
    end
  end

  describe 'PATCH confirm' do
    context 'with invalid provider relationship permissions params' do
      it 'responds with 404' do
        patch provider_interface_confirm_provider_relationship_permissions_path(
          ratifying_provider_id: 1,
          training_provider_id: 1,
        )

        expect(response.status).to eq(404)
      end
    end
  end

  describe 'PATCH update' do
    context 'without related provider params' do
      it 'responds with 404' do
        patch provider_interface_update_provider_relationship_permissions_path(
          ratifying_provider_id: 1,
          training_provider_id: 1,
        )

        expect(response.status).to eq(404)
      end
    end
  end
end
