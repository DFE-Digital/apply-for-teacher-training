require 'rails_helper'

RSpec.describe 'OneLoginController' do
  before do
    FeatureFlag.activate(:one_login_candidate_sign_in)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:onelogin] = omniauth_hash
  end

  let(:omniauth_hash) do
    OmniAuth::AuthHash.new(
      {
        provider: 'onelogin',
        uid: '123',
        info: {
          email: 'test@email.com',
        },
        credentials: {
          id_token: 'id_token',
        },
      },
    )
  end

  describe 'GET /auth/onelogin/callback' do
    it 'redirects to candidate_interface_interstitial_path' do
      candidate = create(:candidate)
      create(:one_login_auth, candidate:, token: '123')

      get auth_onelogin_callback_path

      expect(response).to redirect_to(candidate_interface_interstitial_path)
    end

    context 'when there is no omniauth_hash' do
      let(:omniauth_hash) { nil }

      it 'returns unprocessable_entity' do
        get auth_onelogin_callback_path

        expect(response).to have_http_status(:unprocessable_entity)
      end
    end

    context 'when candidate has a different onelogin token than the one returned by onelogin' do
      it 'redirects to auth_onelogin_sign_out_path' do
        candidate = create(:candidate, email_address: 'test@email.com')
        create(:one_login_auth, candidate:, token: '456')

        get auth_onelogin_callback_path

        expect(response).to redirect_to(auth_onelogin_sign_out_path)
        expect(session[:one_login_error]).to eq(
          "Candidate #{candidate.id} has a different one login token than the " \
          'user trying to login. Token used to auth 123',
        )
      end
    end
  end

  describe 'GET /auth/onelogin/sign_out' do
    context 'when candidate has a different onelogin token than the one returned by onelogin' do
      it 'redirects to logout_onelogin_path and persists the session error message' do
        candidate = create(:candidate, email_address: 'test@email.com')
        create(:one_login_auth, candidate:, token: '456')

        get auth_onelogin_callback_path # set the session variables
        get auth_onelogin_sign_out_path

        expect(session[:onelogin_id_token]).to be_nil
        expect(session[:one_login_error]).to eq(
          "Candidate #{candidate.id} has a different one login token than the " \
          'user trying to login. Token used to auth 123',
        )

        expect(response).to redirect_to(logout_onelogin_path(id_token_hint: 'id_token'))
      end
    end
  end

  describe 'GET /auth/onelogin/sign_out_complete' do
    context 'when candidate has a different onelogin token than the one returned by onelogin' do
      it 'redirects to logout_onelogin_path and persists the session error message' do
        candidate = create(:candidate, email_address: 'test@email.com')
        create(:one_login_auth, candidate:, token: '456')
        allow(Sentry).to receive(:capture_message)

        get auth_onelogin_callback_path # set the session variables
        get auth_onelogin_sign_out_complete_path

        expect(Sentry).to have_received(:capture_message).with(
          "Candidate #{candidate.id} has a different one login token than the " \
          'user trying to login. Token used to auth 123',
          level: :error,
        )
        expect(response).to redirect_to(internal_server_error_path)
      end
    end

    context 'candidate has no errors' do
      it 'redirects to logout_onelogin_path and persists the session error message' do
        get auth_onelogin_sign_out_complete_path

        expect(response).to redirect_to(
          candidate_interface_create_account_or_sign_in_path,
        )
      end
    end
  end

  describe 'GET /auth/onelogin/failure' do
    it 'redirects to auth_failure_path with one login error' do
      get auth_onelogin_callback_path # set the session variables
      get auth_failure_path(params: { message: 'error_message' })

      expect(session[:one_login_error]).to eq(
        'One login failure with error_message for onelogin_id_token: id_token',
      )
      expect(response).to redirect_to(auth_onelogin_sign_out_path)
    end
  end
end
