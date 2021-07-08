require 'rails_helper'

RSpec.describe 'Viewing organisation settings', type: :request do
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

  def expect_redirect_to_account_page
    expect(response.status).to eq(302)
    expect(response.redirect_url).to eq(provider_interface_account_url)
  end

  describe 'GET show with feature flag off' do
    it 'responds with 302' do
      FeatureFlag.deactivate(:accredited_provider_setting_permissions)
      get provider_interface_organisation_settings_path
      expect_redirect_to_account_page
    end
  end

  context 'with feature flag on' do
    before { FeatureFlag.activate(:accredited_provider_setting_permissions) }

    describe 'GET show without manage users or manage organisations ' do
      it 'responds with 302' do
        get provider_interface_organisation_settings_path
        expect_redirect_to_account_page
      end
    end

    describe 'GET show with manage users' do
      it 'responds with 200' do
        provider_user.provider_permissions.update_all(manage_users: true)
        get provider_interface_organisation_settings_path
        expect(response.status).to eq(200)
      end
    end

    describe 'GET show with manage organisations for set up relationships' do
      it 'responds with 200' do
        provider_user.provider_permissions.update_all(manage_organisations: true)
        create(:provider_relationship_permissions, ratifying_provider: provider)
        get provider_interface_organisation_settings_path
        expect(response.status).to eq(200)
      end
    end

    describe 'GET show with manage organisations for relationship that has not been set up' do
      it 'responds with 302' do
        provider_user.provider_permissions.update_all(manage_organisations: true)
        create(:provider_relationship_permissions, ratifying_provider: provider, setup_at: nil)
        get provider_interface_organisation_settings_path
        expect_redirect_to_account_page
      end
    end
  end
end
