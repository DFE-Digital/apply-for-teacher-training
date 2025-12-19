require 'rails_helper'

RSpec.describe 'SupportDfESignInController' do
  include DfESignInHelpers

  let(:omni_auth_hash) do
    fake_dfe_sign_in_auth_hash(
      email_address: 'some@email.address',
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
      first_name: '',
      last_name: '',
      id_token:,
    )
  end
  let(:id_token) { 'token' }

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:'dfe-support'] = omni_auth_hash
  end

  describe 'GET /auth/dfe/callback' do
    context 'there are no DfE sign omniauth values set' do
      let(:omni_auth_hash) { nil }

      it 'is forbidden by default' do
        get auth_dfe_support_callback_path

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when the Support User does not exist' do
      it 'does not sign in' do
        get auth_dfe_support_callback_path

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when Support User exists with matching dfe_sign_in_uid' do
      let!(:support_user) { create(:support_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

      it 'signs the Support User in' do
        get auth_dfe_support_callback_path

        expect(response).to redirect_to(support_interface_path)
      end
    end

    context 'when a different Support User exists with the same email address' do
      let!(:support_user) { create(:support_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }
      let!(:existing_support_user) { create(:support_user, email_address: 'some@email.address') }

      it 'does not sign the Support User in' do
        get auth_dfe_support_callback_path

        expect(response).to have_http_status(:forbidden)
      end
    end

    context 'when separate dsi controllers flag is off' do
      it 'redirect to DfESignInController controller' do
        FeatureFlag.deactivate(:separate_dsi_controllers)
        get auth_dfe_support_callback_path

        expect(response).to redirect_to(auth_dfe_callback_path)
      end
    end
  end

  describe 'GET /auth_dfe_support_sign_out' do
    it 'redirect to support interface' do
      get auth_dfe_support_sign_out_path

      expect(response).to redirect_to(support_interface_path)
    end
  end
end
