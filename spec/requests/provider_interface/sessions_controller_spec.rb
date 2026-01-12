require 'rails_helper'

RSpec.describe ProviderInterface::SessionsController do
  let(:provider) { create(:provider) }
  let(:provider_user) { create(:provider_user, providers: [provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

  describe '#new' do
    let(:support_user) { create(:support_user, dfe_sign_in_uid: 'SUPPORT_DFE_SIGN_IN_UID') }
    let(:dfe_sign_in_user) do
      DfESignInUser.new(
        email_address: support_user.email_address,
        dfe_sign_in_uid: support_user.dfe_sign_in_uid,
        first_name: support_user.first_name,
        last_name: support_user.last_name,
      )
    end

    it 'redirects to applications when impersonation is active' do
      support_user.impersonated_provider_user = provider_user

      allow(DfESignInUser).to receive(:load_from_session).and_return(dfe_sign_in_user)
      allow(SupportUser).to receive(:load_from_session).and_return(support_user)
      get provider_interface_sign_in_path

      expect(response).to have_http_status(:found)
      expect(response.redirect_url).to eq(provider_interface_applications_url)
    end
  end
end
