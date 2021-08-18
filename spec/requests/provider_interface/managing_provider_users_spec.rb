require 'rails_helper'

RSpec.describe 'ProviderUserController actions' do
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

  context 'when the account_and_org_settings_changes feature flag is off' do
    before { FeatureFlag.deactivate(:account_and_org_settings_changes) }

    context 'when the user is not permitted to manage users' do
      it 'redirects GET requests to index' do
        get provider_interface_provider_users_path

        expect(response).to be_forbidden
      end

      it 'redirects GET requests to show' do
        another_user = create(:provider_user, providers: [provider])
        get provider_interface_provider_user_path(another_user)

        expect(response).to be_forbidden
      end

      it 'redirects GET requests to edit-providers' do
        another_user = create(:provider_user, providers: [provider])
        get provider_interface_provider_user_edit_providers_path(another_user)

        expect(response).to be_forbidden
      end
    end
  end
end
