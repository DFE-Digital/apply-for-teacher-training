require 'rails_helper'

RSpec.describe ProviderInterface::UserInvitation::PersonalDetailsController do
  include DfESignInHelpers

  let(:managing_user) { create(:provider_user, :with_manage_organisations, :with_manage_users, providers: [provider]) }
  let(:provider) { create(:provider, :with_signed_agreement) }

  before do
    allow(DfESignInUser).to receive(:load_from_session).and_return(managing_user)

    user_exists_in_dfe_sign_in(email_address: managing_user.email_address)
  end

  context 'when the account_and_org_settings_changes feature flag is on' do
    before { FeatureFlag.activate(:account_and_org_settings_changes) }

    it 'returns a success response for GET new' do
      get new_provider_interface_organisation_settings_organisation_user_invitation_personal_details_path(provider)

      expect(response.status).to eq(200)
    end

    it 'tracks validation errors on POST create' do
      expect {
        post provider_interface_organisation_settings_organisation_user_invitation_personal_details_path(provider),
             params: { provider_interface_invite_user_wizard: { email_address: managing_user.email_address, first_name: 'First', last_name: 'Last' } }
      }.to change(ValidationError, :count).by(1)
    end

    context 'when a user does not have manage users permissions' do
      let(:managing_user) { create(:provider_user, :with_manage_organisations, providers: [provider]) }

      it 'responds with a 403 on GET new' do
        get new_provider_interface_organisation_settings_organisation_user_invitation_personal_details_path(provider)

        expect(response.status).to eq(403)
      end

      it 'responds with a 403 on POST create' do
        post provider_interface_organisation_settings_organisation_user_invitation_personal_details_path(provider)

        expect(response.status).to eq(403)
      end
    end
  end

  context 'when the account_and_org_settings_changes feature flag is off' do
    before { FeatureFlag.deactivate(:account_and_org_settings_changes) }

    it 'redirects to the org settings page' do
      get new_provider_interface_organisation_settings_organisation_user_invitation_personal_details_path(provider)

      expect(response.status).to eq(302)
      expect(response.redirect_url).to eq(provider_interface_organisation_settings_url)
    end
  end
end
