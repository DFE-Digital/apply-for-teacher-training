require 'rails_helper'

RSpec.describe ProviderInterface::UserInvitation::ReviewController do
  include DfESignInHelpers
  include DsiAPIHelper
  include ModelWithErrorsStubHelper

  let(:managing_user) { create(:provider_user, :with_manage_organisations, :with_manage_users, providers: [provider]) }
  let(:provider) { create(:provider, :with_signed_agreement) }
  let(:store_data) { { permissions: [] }.to_json }

  before do
    allow(DfESignInUser).to receive(:load_from_session).and_return(managing_user)

    user_exists_in_dfe_sign_in(email_address: managing_user.email_address)

    store = instance_double(WizardStateStores::RedisStore, read: store_data)
    allow(WizardStateStores::RedisStore).to receive(:new).and_return(store)
  end

  context 'when the wizard is invalid' do
    before do
      stub_model_instance_with_errors(
        ProviderInterface::InviteUserWizard,
        valid?: false,
        email_address: '',
        first_name: '',
        last_name: '',
        permissions: [],
        previous_step: :permissions,
      )
    end

    it 'tracks validation errors on POST commit' do
      expect {
        post provider_interface_organisation_settings_organisation_user_invitation_commit_path(provider),
             params: {}
      }.to change(ValidationError, :count).by(1)
    end
  end

  context 'when there is nothing in the wizard store' do
    let(:store_data) { nil }

    it 'redirects to the users index page on GET check' do
      get provider_interface_organisation_settings_organisation_user_invitation_check_path(provider)

      expect(response.status).to eq(302)
      expect(response.redirect_url).to eq(provider_interface_organisation_settings_organisation_users_url(provider))
    end

    it 'redirects to the users index page on POST commit' do
      post provider_interface_organisation_settings_organisation_user_invitation_commit_path(provider),
           params: {}

      expect(response.status).to eq(302)
      expect(response.redirect_url).to eq(provider_interface_organisation_settings_organisation_users_url(provider))
    end
  end

  context 'when a user does not have manage users permissions' do
    let(:managing_user) { create(:provider_user, :with_manage_organisations, providers: [provider]) }

    it 'responds with a 403 on GET check' do
      get provider_interface_organisation_settings_organisation_user_invitation_check_path(provider)

      expect(response.status).to eq(403)
    end

    it 'responds with a 403 on POST commit' do
      post provider_interface_organisation_settings_organisation_user_invitation_commit_path(provider)

      expect(response.status).to eq(403)
    end
  end
end
