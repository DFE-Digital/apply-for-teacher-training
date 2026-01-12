require 'rails_helper'

RSpec.describe 'SupportDfESignInController' do
  include DfESignInHelpers

  let(:omni_auth_hash) do
    fake_dfe_sign_in_auth_hash(
      email_address: 'some@email.address',
      dfe_sign_in_uid:,
      first_name: '',
      last_name: '',
      id_token:,
    )
  end
  let(:id_token) { 'token' }
  let(:dfe_sign_in_uid) { 'DFE_SIGN_IN_UID' }

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:'dfe-support'] = omni_auth_hash
  end

  describe 'GET /auth/dfe/callback' do
    context 'there are no DfE sign omniauth values set' do
      let(:omni_auth_hash) { nil }

      it 'redirect to destroy' do
        get auth_dfe_support_callback_path

        expect(response).to redirect_to(auth_dfe_support_destroy_path)
      end
    end

    context 'when the Support User does not exist' do
      it 'does not sign in' do
        get auth_dfe_support_callback_path

        expect(response).to redirect_to(auth_dfe_support_destroy_path)
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

        expect(response).to redirect_to(auth_dfe_support_destroy_path)
      end
    end
  end

  describe 'GET /auth/dfe/destroy' do
    context "when user's dfe sign in session is active" do
      it 'redirect to dfe sign in to log out' do
        ClimateControl.modify(DFE_SIGN_IN_ISSUER: 'https://identityprovider.gov.uk') do
          create(:support_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
          get auth_dfe_support_callback_path
          get auth_dfe_support_destroy_path

          expected_query = {
            id_token_hint: id_token,
            post_logout_redirect_uri: 'http://www.example.com/auth/dfe-support/sign-out',
          }
          expected_url = "https://identityprovider.gov.uk/session/end?#{expected_query.to_query}"
          expect(response).to redirect_to(expected_url)
        end
      end
    end

    context "when user's dfe sign in session is not active" do
      it 'redirect to sign out' do
        get auth_dfe_support_destroy_path

        expect(response).to redirect_to(auth_dfe_support_sign_out_path)
      end
    end
  end

  describe 'GET /auth_dfe_support_sign_out' do
    context 'when unauthorized_dsi_support_uid' do
      let(:dfe_sign_in_uid) { 'wrong' }

      it 'renders forbidden page' do
        get auth_dfe_support_callback_path
        get auth_dfe_support_sign_out_path

        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include('Your account is not authorized')
      end
    end

    it 'redirect to support interface' do
      get auth_dfe_support_sign_out_path

      expect(response).to redirect_to(support_interface_path)
    end
  end
end
