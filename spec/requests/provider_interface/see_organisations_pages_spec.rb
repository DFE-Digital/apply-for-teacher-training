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

  context 'when the user cannot manage organisations' do
    before { allow(provider_user).to receive(:can_manage_organisations?).and_return(false) }

    describe 'GET index' do
      it 'responds with 403' do
        get provider_interface_organisations_path

        expect(response.status).to eq(403)
      end
    end

    describe 'GET show' do
      it 'responds with 403' do
        get provider_interface_organisation_path(provider)

        expect(response.status).to eq(403)
      end
    end
  end

  context 'when the provider is not associated with the current user' do
    before { allow(provider_user).to receive(:can_manage_organisations?).and_return(true) }

    describe 'GET show' do
      it 'responds with 403' do
        get provider_interface_organisation_path(create(:provider))

        expect(response.status).to eq(403)
      end
    end
  end
end
