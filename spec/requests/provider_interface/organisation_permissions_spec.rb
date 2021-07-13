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

  describe 'GET show with feature flag off' do
    it 'responds with 302' do
      FeatureFlag.deactivate(:accredited_provider_setting_permissions)
      get provider_interface_organisation_settings_organisation_permissions_path
      expect_redirect_to_account_page
    end
  end

  context 'with feature flag on' do
    before { FeatureFlag.activate(:accredited_provider_setting_permissions) }

    describe 'GET show without manage users or manage organisations ' do
      it 'responds with 302' do
        get provider_interface_organisation_settings_organisation_permissions_path
        expect_redirect_to_account_page
      end
    end

    describe 'GET show with a unrelated provider' do
      it 'responds with 404' do
        get provider_interface_organisation_settings_organisation_permission_path(ratifying_provider)
        expect(response.status).to eq(404)
      end
    end
  end
end
