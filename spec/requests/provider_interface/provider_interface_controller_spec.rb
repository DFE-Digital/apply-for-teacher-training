require 'rails_helper'

RSpec.describe ProviderInterface::ProviderInterfaceController do
  include DfESignInHelpers

  let(:provider) { create(:provider) }
  let(:provider_user) { create(:provider_user, :with_manage_organisations, providers: [provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

  before do
    user_exists_in_dfe_sign_in(email_address: provider_user.email_address)
    get auth_dfe_callback_path
  end

  context 'when there are permissions requiring setup' do
    let(:ratifying_provider) { create(:provider) }
    let!(:course) { create(:course, :open, accredited_provider: ratifying_provider, provider:) }
    let!(:permissions) do
      create(
        :provider_relationship_permissions,
        ratifying_provider:,
        training_provider: provider,
        setup_at: nil,
      )
    end

    it 'redirects provider interface requests to the organisation permissions setup controller' do
      get provider_interface_applications_path

      expect(response).to have_http_status(:found)
      expect(response.redirect_url).to eq(provider_interface_organisation_permissions_setup_index_url)
    end
  end
end
