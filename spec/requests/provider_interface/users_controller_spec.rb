require 'rails_helper'

RSpec.describe ProviderInterface::UsersController do
  include DfESignInHelpers

  let(:managing_user) { create(:provider_user, :with_dfe_sign_in, :with_manage_organisations, :with_manage_users, providers: [provider]) }
  let(:provider) { create(:provider) }

  it 'returns a success response for GET index' do
    user_exists_in_dfe_sign_in(email_address: managing_user.email_address)
    get auth_dfe_callback_path
    get provider_interface_organisation_settings_organisation_users_path(provider)

    expect(response).to have_http_status(:ok)
  end

  context 'when a user does not have manage orgs permissions' do
    let(:managing_user) { create(:provider_user, :with_manage_organisations, providers: [provider]) }
    let(:provider_user) { create(:provider_user, :with_dfe_sign_in, providers: [provider]) }

    it 'responds with a 403 on GET confirm_destroy' do
      user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
      get auth_dfe_callback_path
      get confirm_destroy_provider_interface_organisation_settings_organisation_user_path(provider, provider_user)

      expect(response).to have_http_status(:forbidden)
    end

    it 'responds with a 403 on DELETE' do
      user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
      get auth_dfe_callback_path
      delete provider_interface_organisation_settings_organisation_user_path(provider, provider_user)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
