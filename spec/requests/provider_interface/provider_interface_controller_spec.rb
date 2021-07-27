require 'rails_helper'

RSpec.describe ProviderInterface::ProviderInterfaceController do
  let(:provider) { create(:provider, :with_signed_agreement) }
  let(:provider_user) { create(:provider_user, :with_manage_organisations, providers: [provider], dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

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

  context 'when there are permissions requiring setup' do
    let(:ratifying_provider) { create(:provider) }
    let!(:course) { create(:course, :open_on_apply, accredited_provider: ratifying_provider, provider: provider) }
    let!(:permissions) do
      create(
        :provider_relationship_permissions,
        ratifying_provider: ratifying_provider,
        training_provider: provider,
        setup_at: nil,
      )
    end

    it 'redirects provider interface requests to the organisation permissions setup controller' do
      get provider_interface_applications_path

      expect(response.status).to eq(302)
      expect(response.redirect_url).to eq(provider_interface_organisation_permissions_setup_index_url)
    end
  end
end
