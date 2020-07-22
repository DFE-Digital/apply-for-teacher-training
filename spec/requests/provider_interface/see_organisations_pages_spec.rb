require 'rails_helper'

RSpec.describe 'Organisations', type: :request do
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

  context 'when another provider ratifies courses for a provider associated with the current user' do
    describe 'GET show' do
      let(:ratifying_provider) { create(:provider, :with_signed_agreement) }

      before do
        create(
          :provider_relationship_permissions,
          ratifying_provider: ratifying_provider,
          training_provider: provider,
        )

        provider.provider_permissions.update_all(manage_organisations: true)
      end

      it 'trying to view the ratifying provider gives 403' do
        get provider_interface_organisation_path(ratifying_provider)

        expect(response.status).to eq(403)
      end

      it 'trying to view the training provider gives 200' do
        get provider_interface_organisation_path(provider)

        expect(response.status).to eq(200)
      end
    end
  end
end
