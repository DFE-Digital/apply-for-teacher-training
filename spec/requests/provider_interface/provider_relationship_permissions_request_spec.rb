require 'rails_helper'

RSpec.describe 'ProviderRelationshipPermissions', type: :request do
  let(:provider) { create(:provider, :with_signed_agreement) }
  let(:provider_user) { create(:provider_user, providers: [provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

  before do
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

  describe 'invalid provider relationship permissions param' do
    context 'GET edit' do
      it 'responds with 404' do
        get provider_interface_edit_provider_relationship_permissions_path(id: 666)

        expect(response.status).to eq(404)
      end
    end

    context 'PATCH update' do
      it 'responds with 404' do
        patch provider_interface_update_provider_relationship_permissions_path(id: 666)

        expect(response.status).to eq(404)
      end
    end
  end

  describe 'with a provider relationship not associated with the current user' do
    let(:ratifying_provider) { create(:provider) }
    let(:training_provider) { create(:provider) }

    let(:permissions) do
      permissions = create(
        :provider_relationship_permissions,
        ratifying_provider: ratifying_provider,
        training_provider: training_provider,
      )
      provider_user.provider_permissions.update_all(manage_organisations: true)
      permissions
    end

    context 'GET edit' do
      it 'responds with 403 Forbidden' do
        get provider_interface_edit_provider_relationship_permissions_path(permissions)

        expect(response.status).to eq(403)
      end
    end

    describe 'PATCH update' do
      it 'responds with 403 Forbidden' do
        patch provider_interface_update_provider_relationship_permissions_path(permissions)

        expect(response.status).to eq(403)
      end
    end
  end

  describe 'validation errors' do
    let(:permissions) do
      permissions = create(
        :provider_relationship_permissions,
        ratifying_provider: create(:provider),
        training_provider: provider,
        setup_at: nil,
      )
      provider_user.provider_permissions.update_all(manage_organisations: true)
      permissions
    end

    it 'tracks validation errors on save_permissions' do
      stub_model_instance_with_errors(
        ProviderInterface::ProviderRelationshipPermissionsSetupWizard,
        valid?: false,
        previous_step: :check,
        current_permissions_form: instance_double(
          ProviderInterface::ProviderRelationshipPermissionsSetupWizard::PermissionsForm,
          id: '1', make_decisions: nil, view_safeguarding_information: nil, view_diversity_information: nil,
        ),
      )

      expect {
        post provider_interface_save_provider_relationship_permissions_path(permissions)
      }.to change(ValidationError, :count).by(1)
    end
  end
end
