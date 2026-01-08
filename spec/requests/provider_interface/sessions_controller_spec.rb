require 'rails_helper'

RSpec.describe ProviderInterface::SessionsController do
  include DfESignInHelpers

  let(:provider) { create(:provider) }
  let(:provider_user) { create(:provider_user, providers: [provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

  describe '#new' do
    let(:support_user) { create(:support_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }
    let(:dfe_sign_in_user) do
      DfESignInUser.new(
        email_address: support_user.email_address,
        dfe_sign_in_uid: support_user.dfe_sign_in_uid,
        first_name: support_user.first_name,
        last_name: support_user.last_name,
      )
    end

    it 'redirects to applications when impersonation is active' do
      support_user_exists_dsi(email_address: support_user.email_address)

      get auth_dfe_support_callback_path
      post support_interface_provider_user_impersonate_path(provider_user)
      get provider_interface_sign_in_path

      expect(response).to have_http_status(:found)
      expect(response.redirect_url).to eq(provider_interface_applications_url)
    end
  end
end
