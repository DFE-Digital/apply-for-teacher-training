require 'rails_helper'

RSpec.describe 'Viewing organisation permissions', type: :request do
  let(:training_provider) { create(:provider, :with_signed_agreement) }
  let(:ratifying_provider) { create(:provider, :with_signed_agreement) }
  let(:relationship) { create(:provider_relationship_permissions, training_provider: training_provider, ratifying_provider: ratifying_provider) }
  let(:provider_user) { create(:provider_user, :with_manage_organisations, providers: [training_provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

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

  describe 'GET organisations with feature flag off' do
    it 'responds with 302' do
      FeatureFlag.deactivate(:accredited_provider_setting_permissions)
      get provider_interface_organisation_settings_organisations_path
      expect(response.status).to eq(302)
      expect(response.redirect_url).to eq(provider_interface_account_url)
    end
  end

  context 'with feature flag on' do
    before { FeatureFlag.activate(:accredited_provider_setting_permissions) }

    describe 'without manage organisations' do
      let(:provider_user) { create(:provider_user, providers: [training_provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

      it 'GET index responds with 403' do
        get provider_interface_organisation_settings_organisation_organisation_permissions_path(training_provider)
        expect(response.status).to eq(403)
      end

      it 'GET edit responds with 403' do
        get edit_provider_interface_organisation_settings_organisation_organisation_permission_path(relationship, organisation_id: training_provider.id)
        expect(response.status).to eq(403)
      end

      it 'PATCH update responds with 403' do
        patch provider_interface_organisation_settings_organisation_organisation_permission_path(relationship, organisation_id: training_provider)
        expect(response.status).to eq(403)
      end
    end

    describe 'with a unrelated provider' do
      it 'GET index responds with 404' do
        get provider_interface_organisation_settings_organisation_organisation_permissions_path(ratifying_provider)
        expect(response.status).to eq(404)
      end

      it 'GET edit responds with 404' do
        get edit_provider_interface_organisation_settings_organisation_organisation_permission_path(relationship, organisation_id: ratifying_provider)
        expect(response.status).to eq(404)
      end

      it 'PATCH update responds with 404' do
        patch provider_interface_organisation_settings_organisation_organisation_permission_path(training_provider, organisation_id: ratifying_provider)
        expect(response.status).to eq(404)
      end
    end

    describe 'with a unrelated relationship' do
      it 'GET edit responds with 404' do
        get edit_provider_interface_organisation_settings_organisation_organisation_permission_path(create(:provider_relationship_permissions), organisation_id: training_provider)
        expect(response.status).to eq(404)
      end

      it 'PATCH update responds with 404' do
        other_relationship = create(:provider_relationship_permissions)
        patch provider_interface_organisation_settings_organisation_organisation_permission_path(other_relationship, organisation_id: training_provider)
        expect(response.status).to eq(404)
      end
    end
  end
end
