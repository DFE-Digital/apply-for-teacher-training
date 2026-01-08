require 'rails_helper'

RSpec.describe ProviderInterface::UserPermissionsController do
  include DfESignInHelpers

  let(:managing_user) { create(:provider_user, :with_dfe_sign_in, :with_manage_organisations, :with_manage_users, providers: [provider]) }
  let(:provider) { create(:provider) }

  before do
    user_exists_in_dfe_sign_in(email_address: managing_user.email_address)
    get auth_dfe_callback_path
  end

  it 'returns a success response for GET index' do
    get provider_interface_organisation_settings_organisation_users_path(provider)

    expect(response).to have_http_status(:ok)
  end

  it 'redirects back to the edit user permissions page when the wizard store is empty' do
    get check_provider_interface_organisation_settings_organisation_user_permissions_path(provider, managing_user)

    expect(response).to have_http_status(:found)
    expect(response.redirect_url).to eq(edit_provider_interface_organisation_settings_organisation_user_permissions_url(provider, managing_user))
  end

  context 'when a user does not have manage orgs permissions' do
    let(:managing_user) { create(:provider_user, :with_dfe_sign_in, :with_manage_organisations, providers: [provider]) }
    let(:provider_user) { create(:provider_user, providers: [provider]) }

    it 'responds with a 403 on GET edit' do
      get edit_provider_interface_organisation_settings_organisation_user_permissions_path(provider, provider_user)

      expect(response).to have_http_status(:forbidden)
    end

    it 'responds with a 403 on PUT' do
      put provider_interface_organisation_settings_organisation_user_permissions_path(provider, provider_user)

      expect(response).to have_http_status(:forbidden)
    end

    it 'responds with a 403 on GET check' do
      get check_provider_interface_organisation_settings_organisation_user_permissions_path(provider, provider_user)

      expect(response).to have_http_status(:forbidden)
    end

    it 'responds with a 403 on PUT commit' do
      put commit_provider_interface_organisation_settings_organisation_user_permissions_path(provider, provider_user)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
