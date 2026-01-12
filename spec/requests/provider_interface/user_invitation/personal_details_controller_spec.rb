require 'rails_helper'

RSpec.describe ProviderInterface::UserInvitation::PersonalDetailsController do
  include DfESignInHelpers

  let(:managing_user) { create(:provider_user, :with_manage_organisations, :with_manage_users, providers: [provider]) }
  let(:provider) { create(:provider) }
  let(:store_data) { { first_name: 'First' }.to_json }

  before do
    allow(DfESignInUser).to receive(:load_from_session).and_return(managing_user)

    user_exists_in_dfe_sign_in(email_address: managing_user.email_address)

    store = instance_double(WizardStateStores::RedisStore, read: store_data, write: nil, delete: nil)
    allow(WizardStateStores::RedisStore).to receive(:new).and_return(store)
  end

  it 'returns a success response for GET new' do
    get new_provider_interface_organisation_settings_organisation_user_invitation_personal_details_path(provider)

    expect(response).to have_http_status(:ok)
  end

  it 'tracks validation errors on POST create' do
    expect {
      post provider_interface_organisation_settings_organisation_user_invitation_personal_details_path(provider),
           params: { provider_interface_invite_user_wizard: { email_address: managing_user.email_address, first_name: 'First', last_name: 'Last' } }
    }.to change(ValidationError, :count).by(1)
  end

  context 'when there is nothing in the wizard store' do
    let(:store_data) { nil }

    it 'returns a success response for GET new' do
      get new_provider_interface_organisation_settings_organisation_user_invitation_personal_details_path(provider)

      expect(response).to have_http_status(:ok)
    end

    it 'redirects to the users index page on POST create' do
      post provider_interface_organisation_settings_organisation_user_invitation_personal_details_path(provider),
           params: { provider_interface_invite_user_wizard: { email_address: managing_user.email_address, first_name: 'First', last_name: 'Last' } }

      expect(response).to have_http_status(:found)
      expect(response.redirect_url).to eq(provider_interface_organisation_settings_organisation_users_url(provider))
    end
  end

  context 'when a user does not have manage users permissions' do
    let(:managing_user) { create(:provider_user, :with_manage_organisations, providers: [provider]) }

    it 'responds with a 403 on GET new' do
      get new_provider_interface_organisation_settings_organisation_user_invitation_personal_details_path(provider)

      expect(response).to have_http_status(:forbidden)
    end

    it 'responds with a 403 on POST create' do
      post provider_interface_organisation_settings_organisation_user_invitation_personal_details_path(provider)

      expect(response).to have_http_status(:forbidden)
    end
  end
end
