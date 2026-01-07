require 'rails_helper'

RSpec.describe 'DfESignInController#callbacks' do
  include DfESignInHelpers

  let(:omni_auth_hash) do
    fake_dfe_sign_in_auth_hash(
      email_address:,
      dfe_sign_in_uid: 'DFE_SIGN_IN_UID',
      first_name: '',
      last_name: '',
      id_token:,
    )
  end
  let(:id_token) { 'token' }
  let(:email_address) { 'some@email.address' }

  before do
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:dfe] = omni_auth_hash
  end

  describe 'GET /auth/dfe/callback' do
    context 'there are no DfE sign omniauth values set' do
      let(:omni_auth_hash) { nil }

      it 'redirect to destroy' do
        get auth_dfe_callback_path

        expect(response).to redirect_to(auth_dfe_destroy_path)
      end
    end

    context 'when Provider User exists with matching dfe_sign_in_uid' do
      let!(:provider_user) { create(:provider_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }

      it 'signs the Provider User in' do
        get auth_dfe_callback_path

        expect(response).to redirect_to(provider_interface_path)
      end
    end

    context 'when a different Provider User exists with the same email address' do
      let!(:provider_user) { create(:provider_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID') }
      let!(:existing_provider_user) { create(:provider_user, email_address: 'some@email.address') }

      it 'does not sign the Provider User in' do
        get auth_dfe_callback_path

        expect(response).to redirect_to(auth_dfe_destroy_path)
      end
    end
  end

  describe 'GET /auth/dfe/destroy' do
    context "when user's dfe sign in session is active" do
      it 'redirect to dfe sign in to log out' do
        ClimateControl.modify(DFE_SIGN_IN_ISSUER: 'https://identityprovider.gov.uk') do
          create(:provider_user, dfe_sign_in_uid: 'DFE_SIGN_IN_UID')
          get auth_dfe_callback_path
          get auth_dfe_destroy_path

          expected_query = {
            id_token_hint: id_token,
            post_logout_redirect_uri: 'http://www.example.com/auth/dfe/sign-out',
          }
          expected_url = "https://identityprovider.gov.uk/session/end?#{expected_query.to_query}"
          expect(response).to redirect_to(expected_url)
        end
      end

      context "when user's dfe sign in session is not active" do
        it 'redirect to sign out' do
          get auth_dfe_destroy_path

          expect(response).to redirect_to(auth_dfe_sign_out_path)
        end
      end
    end
  end

  describe 'GET /auth_dfe_sign_out' do
    it 'redirect to provider interface' do
      get auth_dfe_sign_out_path

      expect(response).to redirect_to(provider_interface_path)
    end

    context 'email not recognised' do
      let(:email_address) { 'wrong@email.address' }

      it 'renders forbidden layout if email not recognised' do
        get auth_dfe_callback_path
        get auth_dfe_sign_out_path

        expect(response).to have_http_status(:forbidden)
        expect(response.body).to include('We can’t find an ‘Apply for teacher training’ account associated with that address.')
      end
    end
  end
end
