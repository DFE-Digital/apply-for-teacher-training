require 'rails_helper'

RSpec.describe 'OneLoginController' do
  before do
    FeatureFlag.activate(:one_login_candidate_sign_in)
    OmniAuth.config.test_mode = true
    OmniAuth.config.mock_auth[:one_login] = omniauth_hash
  end

  let(:omniauth_hash) do
    OmniAuth::AuthHash.new(
      {
        provider: 'one_login',
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

  describe 'GET /auth/one-login/callback' do
    it 'redirects to candidate_interface_interstitial_path' do
      candidate = create(:candidate)
      create(:one_login_auth, candidate:, token: '123')

      get auth_one_login_callback_path

      expect(response).to redirect_to(candidate_interface_interstitial_path)
    end

    context 'when there is no omniauth_hash' do
      let(:omniauth_hash) { nil }

      it 'redirects to internal_server_error' do
        get auth_one_login_callback_path

        expect(response).to redirect_to internal_server_error_path
      end
    end

    context 'when candidate has a different one login token than the one returned by one login' do
      it 'redirects to auth_one_login_sign_out_path' do
        candidate = create(:candidate, email_address: 'test@email.com')
        create(:one_login_auth, candidate:, token: '456')
        allow(Sentry).to receive(:capture_message)

        expect {
          get auth_one_login_callback_path
        }.to change(SessionError, :count).by(1)

        expect(response).to redirect_to(auth_one_login_sign_out_path)
        expect(session[:session_error_id]).to eq(SessionError.last.id)

        expect(Sentry).to have_received(:capture_message).with(
          "One login session error, check session_error record #{SessionError.last.id}",
          level: :error,
        )
      end
    end
  end

  describe 'GET /auth/one-login-developer/callback' do
    before do
      Rails.application.env_config['omniauth.auth'] = omniauth_one_login_developer
    end

    let(:omniauth_one_login_developer) do
      OmniAuth.config.mock_auth[:one_login_developer] = omniauth_developer_hash
    end
    let(:omniauth_developer_hash) do
      OmniAuth::AuthHash.new(
        {
          provider: :one_login_developer,
          uid:,
          credentials: {
            id_token: 'id_token',
          },
        },
      )
    end
    let(:uid) { 'dev-candidate' }

    it 'logs in the candidate' do
      candidate = create(:candidate)
      create(:one_login_auth, candidate:, token: 'dev-candidate')

      get auth_one_login_developer_callback_path

      expect(response).to redirect_to(candidate_interface_interstitial_path)
    end

    context 'when token is not dev-candidate' do
      it 'creates a candidate and logs them in' do
        get auth_one_login_developer_callback_path

        expect(response).to redirect_to(candidate_interface_create_account_or_sign_in_path)
      end
    end

    context 'when uid is blank' do
      let(:uid) { nil }

      it 'redirects to sign in page' do
        candidate = create(:candidate)
        create(:one_login_auth, candidate:, token: '123')

        get auth_one_login_developer_callback_path

        expect(response).to redirect_to(candidate_interface_create_account_or_sign_in_path)
      end
    end
  end

  describe 'GET /auth/one-login/sign-out' do
    it 'redirects to one_login logout url' do
      create(:candidate, email_address: 'test@email.com')

      get auth_one_login_callback_path # set the session variables
      get auth_one_login_sign_out_path

      params = {
        post_logout_redirect_uri: URI(auth_one_login_sign_out_complete_url),
        id_token_hint: 'id_token',
      }
      one_login_logout_url = URI.parse("#{ENV['GOVUK_ONE_LOGIN_ISSUER_URL']}logout").tap do |uri|
        uri.query = URI.encode_www_form(params)
      end.to_s

      expect(response).to redirect_to(one_login_logout_url)
    end

    context 'when candidate has a different one login token than the one returned by one login' do
      it 'redirects to one_login logout url and persists the session error message' do
        candidate = create(:candidate, email_address: 'test@email.com')
        create(:one_login_auth, candidate:, token: '456')
        allow(Sentry).to receive(:capture_message)

        expect {
          get auth_one_login_callback_path # set the session variables
        }.to change(SessionError, :count).by(1)

        get auth_one_login_sign_out_path

        expect(Sentry).to have_received(:capture_message).with(
          "One login session error, check session_error record #{SessionError.last.id}",
          level: :error,
        )

        expect(session[:session_error_id]).to eq(SessionError.last.id)

        params = {
          post_logout_redirect_uri: URI(auth_one_login_sign_out_complete_url),
          id_token_hint: 'id_token',
        }
        one_login_url = URI.parse("#{ENV['GOVUK_ONE_LOGIN_ISSUER_URL']}logout").tap do |uri|
          uri.query = URI.encode_www_form(params)
        end.to_s

        expect(response).to redirect_to(one_login_url)
      end
    end

    context 'when one login bypass is true' do
      it 'redirects to sign_in page' do
        allow(OneLogin).to receive(:bypass?).and_return(true)

        get auth_one_login_sign_out_path
        expect(response).to redirect_to candidate_interface_create_account_or_sign_in_path
      end
    end

    context 'session id_token is nil' do
      it 'redirects to sign_in page' do
        get auth_one_login_sign_out_path
        expect(response).to redirect_to candidate_interface_create_account_or_sign_in_path
      end
    end
  end
  # 137

  describe 'GET /auth/one-login/sign-out-complete' do
    context 'when candidate has a different one login token than the one returned by one login' do
      it 'redirects to logout_one_login_path and persists the session error message' do
        candidate = create(:candidate, email_address: 'test@email.com')
        create(:one_login_auth, candidate:, token: '456')
        allow(Sentry).to receive(:capture_message)

        expect {
          get auth_one_login_callback_path # set the session variables
        }.to change(SessionError, :count).by(1)

        get auth_one_login_sign_out_complete_path

        expect(Sentry).to have_received(:capture_message).with(
          "One login session error, check session_error record #{SessionError.last.id}",
          level: :error,
        )
        expect(response).to redirect_to(candidate_interface_wrong_email_address_path)
      end
    end

    context 'candidate has no errors' do
      it 'redirects to logout_one_login_path and persists the session error message' do
        get auth_one_login_sign_out_complete_path

        expect(response).to redirect_to(
          candidate_interface_create_account_or_sign_in_path,
        )
      end
    end
  end

  describe 'GET /auth/one-login/failure' do
    it 'redirects to auth_failure_path with one login error' do
      allow(Sentry).to receive(:capture_message)
      get auth_one_login_callback_path # set the session variables

      expect {
        get auth_failure_path(params: { message: 'error_message' })
      }.to change(SessionError, :count).by(1)

      expect(Sentry).to have_received(:capture_message).with(
        "One login failure with error_message, check session_error record #{SessionError.last.id}",
        level: :error,
      )
      expect(session[:session_error_id]).to eq(SessionError.last.id)
      expect(response).to redirect_to(auth_one_login_sign_out_path)

      # a failure will need to call sign_out_complete
      get auth_one_login_sign_out_complete_path

      expect(response).to redirect_to(internal_server_error_path)
    end
  end
end
