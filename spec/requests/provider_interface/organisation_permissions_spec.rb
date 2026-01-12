require 'rails_helper'

RSpec.describe 'Viewing organisation permissions' do
  include DfESignInHelpers

  let(:training_provider) { create(:provider) }
  let(:ratifying_provider) { create(:provider) }
  let(:relationship) { create(:provider_relationship_permissions, training_provider:, ratifying_provider:) }
  let(:provider_user) { create(:provider_user, :with_dfe_sign_in, :with_manage_organisations, providers: [training_provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

  before do
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
    get auth_dfe_callback_path
  end

  describe 'without manage organisations' do
    let(:provider_user) { create(:provider_user, providers: [training_provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

    it 'GET index responds with 200' do
      get provider_interface_organisation_settings_organisation_organisation_permissions_path(training_provider)
      expect(response).to have_http_status(:ok)
    end

    it 'GET edit responds with 403' do
      get edit_provider_interface_organisation_settings_organisation_organisation_permission_path(relationship, organisation_id: training_provider.id)
      expect(response).to have_http_status(:forbidden)
    end

    it 'PATCH update responds with 403' do
      patch provider_interface_organisation_settings_organisation_organisation_permission_path(relationship, organisation_id: training_provider)
      expect(response).to have_http_status(:forbidden)
    end
  end

  describe 'with a unrelated provider' do
    it 'GET index responds with 404' do
      get provider_interface_organisation_settings_organisation_organisation_permissions_path(ratifying_provider)
      expect(response).to have_http_status(:not_found)
    end

    it 'GET edit responds with 404' do
      get edit_provider_interface_organisation_settings_organisation_organisation_permission_path(relationship, organisation_id: ratifying_provider)
      expect(response).to have_http_status(:not_found)
    end

    it 'PATCH update responds with 404' do
      patch provider_interface_organisation_settings_organisation_organisation_permission_path(training_provider, organisation_id: ratifying_provider)
      expect(response).to have_http_status(:not_found)
    end
  end

  describe 'with a unrelated relationship' do
    it 'GET edit responds with 404' do
      get edit_provider_interface_organisation_settings_organisation_organisation_permission_path(create(:provider_relationship_permissions), organisation_id: training_provider)
      expect(response).to have_http_status(:not_found)
    end

    it 'PATCH update responds with 404' do
      other_relationship = create(:provider_relationship_permissions)
      patch provider_interface_organisation_settings_organisation_organisation_permission_path(other_relationship, organisation_id: training_provider)
      expect(response).to have_http_status(:not_found)
    end
  end
end
