require 'rails_helper'

RSpec.describe ProviderInterface::UserInvitation::PermissionsController do
  include DfESignInHelpers

  let(:managing_user) { create(:provider_user, :with_manage_organisations, :with_manage_users, providers: [provider]) }
  let(:provider) { create(:provider) }

  before do
    allow(DfESignInUser).to receive(:load_from_session).and_return(managing_user)

    user_exists_in_dfe_sign_in(email_address: managing_user.email_address)
  end

  context 'when there is nothing in the wizard store' do
    let(:store_data) { nil }

    before do
      store = instance_double(WizardStateStores::RedisStore, read: store_data, write: nil)
      allow(WizardStateStores::RedisStore).to receive(:new).and_return(store)
    end

    it 'redirects to the users index page on GET new' do
      get new_provider_interface_organisation_settings_organisation_user_invitation_permissions_path(provider)

      expect(response).to have_http_status(:found)
      expect(response.redirect_url).to eq(provider_interface_organisation_settings_organisation_users_url(provider))
    end

    it 'redirects to the users index page on POST create' do
      post provider_interface_organisation_settings_organisation_user_invitation_permissions_path(provider),
           params: { provider_interface_invite_user_wizard: { permissions: [] } }

      expect(response).to have_http_status(:found)
      expect(response.redirect_url).to eq(provider_interface_organisation_settings_organisation_users_url(provider))
    end
  end
end
