require 'rails_helper'

RSpec.describe 'Set up ProviderRelationshipPermissions', type: :request do
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

  describe 'when there are permissions to set up' do
    let(:provider_user) { create(:provider_user, :with_manage_organisations, providers: [provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

    before do
      ratifying_provider = create(:provider)
      create(
        :provider_relationship_permissions,
        ratifying_provider: ratifying_provider,
        training_provider: provider,
        setup_at: nil,
      )
      create(:course, :open_on_apply, accredited_provider: ratifying_provider, provider: provider)
    end

    context 'when the accredited_provider_setting_permissions flag is on' do
      before { FeatureFlag.activate(:accredited_provider_setting_permissions) }

      it 'redirects to the new setup start page' do
        get provider_interface_provider_relationship_permissions_organisations_path

        expect(response.status).to eq(302)
        expect(response.redirect_url).to eq(provider_interface_organisation_permissions_setup_index_url)
      end
    end

    context 'when the accredited_provider_setting_permissions flag is off' do
      before { FeatureFlag.deactivate(:accredited_provider_setting_permissions) }

      it 'returns a 200 on the setup start page' do
        get provider_interface_provider_relationship_permissions_organisations_path

        expect(response.status).to eq(200)
      end
    end
  end

  describe 'invalid provider relationship params' do
    context 'GET edit' do
      it 'responds with 404' do
        get provider_interface_provider_relationship_permissions_organisations_path

        expect(response.status).to eq(404)
      end
    end

    context 'GET set_permissions' do
      it 'responds with 404' do
        get provider_interface_setup_provider_relationship_permissions_path(id: 1)

        expect(response.status).to eq(404)
      end
    end

    context 'POST save_permissions' do
      it 'responds with 404' do
        post provider_interface_save_provider_relationship_permissions_path(id: 1)

        expect(response.status).to eq(404)
      end
    end

    context 'GET check' do
      it 'responds with 404' do
        get provider_interface_check_provider_relationship_permissions_path

        expect(response.status).to eq(404)
      end
    end

    context 'POST commit' do
      it 'responds with 404' do
        post provider_interface_commit_provider_relationship_permissions_path

        expect(response.status).to eq(404)
      end
    end
  end

  describe 'with a provider relationship not associated with the current user' do
    let(:ratifying_provider) { create(:provider) }
    let(:training_provider) { create(:provider) }

    let(:permissions) do
      create(
        :provider_relationship_permissions,
        ratifying_provider: ratifying_provider,
        training_provider: training_provider,
        setup_at: nil,
      )
    end

    before do
      create(
        :provider_relationship_permissions,
        ratifying_provider: ratifying_provider,
        training_provider: provider,
        setup_at: nil,
      )
      provider_user.provider_permissions.update_all(manage_organisations: true)
    end

    context 'GET setup_permissions' do
      it 'responds with 403 Forbidden' do
        get provider_interface_setup_provider_relationship_permissions_path(permissions.id)

        expect(response.status).to eq(403)
      end
    end

    describe 'POST save_permissions' do
      it 'responds with 403 Forbidden' do
        post provider_interface_save_provider_relationship_permissions_path(permissions.id)

        expect(response.status).to eq(403)
      end
    end
  end

  describe 'when the current user does not have permission to manage organisations' do
    before do
      create(
        :provider_relationship_permissions,
        ratifying_provider: create(:provider),
        training_provider: provider,
        setup_at: Time.zone.now,
      )
    end

    it 'responds with 404' do
      get provider_interface_provider_relationship_permissions_organisations_path

      expect(response.status).to eq(404)
    end
  end

  describe 'when no permissions need setup' do
    before do
      create(
        :provider_relationship_permissions,
        ratifying_provider: create(:provider),
        training_provider: provider,
        setup_at: Time.zone.now,
      )
      provider_user.provider_permissions.update_all(manage_organisations: true)
    end

    it 'redirects to the applications path' do
      get provider_interface_provider_relationship_permissions_organisations_path

      expect(response.status).to eq(302)
      expect(response.redirect_url).to match(/\/provider\/applications$/)
    end
  end
end
