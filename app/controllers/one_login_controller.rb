class OneLoginController < ApplicationController
  include Authentication

  before_action :redirect_to_candidate_sign_in_unless_one_login_enabled
  skip_before_action :require_authentication
  skip_before_action :verify_authenticity_token, only: %i[backchannel_logout]

  def callback
    auth = request.env['omniauth.auth']
    id_token_hint = auth&.credentials&.id_token
    candidate = OneLoginUser.authenticate_or_create_by(auth)

    start_new_session_for(
      candidate:,
      id_token_hint:,
    )

    redirect_to get_redirect_link(request.env['omniauth.origin'])
  rescue StandardError => e
    session_error = SessionError.create!(
      candidate: OneLoginUser.find_candidate(auth),
      id_token_hint:,
      body: e.message,
      omniauth_hash: auth&.to_h,
    )

    if e.is_a?(OneLoginUser::Error)
      session_error.wrong_email_address!
      session[:session_error_id] = session_error.id

      redirect_to auth_one_login_sign_out_path
    else
      redirect_to internal_server_error_path
    end
  end

  def bypass_callback
    one_login_user_bypass = OneLoginUserBypass.new(
      token: request.env['omniauth.auth']&.uid,
    )
    candidate = one_login_user_bypass.authenticate

    if candidate.present?
      start_new_session_for(candidate:)

      redirect_to candidate_interface_interstitial_path
    else
      flash[:warning] = one_login_user_bypass.errors.full_messages.join('\n')
      redirect_to candidate_interface_create_account_or_sign_in_path
    end
  end

  def sign_out
    session_error = SessionError.find_by(id: session[:session_error_id])
    id_token_hint = if authenticated?
                      Current.session&.id_token_hint
                    else
                      session_error&.id_token_hint
                    end

    terminate_session

    session[:session_error_id] = session_error.id if session_error.present?
    if OneLogin.bypass? || id_token_hint.nil?
      redirect_to candidate_interface_create_account_or_sign_in_path
    else
      # Go back to one login to sign out the user on their end as well
      redirect_to logout_one_login(id_token_hint), allow_other_host: true
    end
  end

  def sign_out_complete
    if session[:session_error_id].present?
      session_error = SessionError.find_by(id: session[:session_error_id])
      reset_session

      path_to_error_page = if session_error&.wrong_email_address?
                             candidate_interface_wrong_email_address_path
                           else
                             internal_server_error_path
                           end

      redirect_to path_to_error_page
    else
      redirect_to candidate_interface_create_account_or_sign_in_path
    end
  end

  def backchannel_logout
    return head :bad_request if params[:logout_token].blank?

    token = OmniAuth::GovukOneLogin::BackchannelLogoutUtility.new(
      client_id: ENV.fetch('GOVUK_ONE_LOGIN_CLIENT_ID', ''),
      idp_base_url: ENV.fetch('GOVUK_ONE_LOGIN_ISSUER_URL', ''),
    ).get_sub(logout_token: params[:logout_token])

    return head :bad_request if token.blank?

    one_login_auth = OneLoginAuth.find_by!(token:)
    one_login_auth.candidate.sessions.delete_all

    head :ok
  end

  def failure
    terminate_session
    redirect_to root_path
  end

private

  def get_redirect_link(origin)
    return candidate_interface_interstitial_path if origin.nil?

    uri = URI(origin)
    path_query = Rack::Utils.parse_nested_query(uri.query).fetch('path', nil)

    candidate_interface_interstitial_path(path: path_query)
  end

  def redirect_to_candidate_sign_in_unless_one_login_enabled
    if FeatureFlag.inactive?(:one_login_candidate_sign_in)
      redirect_to candidate_interface_create_account_or_sign_in_path
    end
  end

  def logout_one_login(id_token_hint)
    params = {
      post_logout_redirect_uri: URI(auth_one_login_sign_out_complete_url),
      id_token_hint:,
    }
    URI.parse("#{ENV['GOVUK_ONE_LOGIN_ISSUER_URL']}logout").tap do |uri|
      uri.query = URI.encode_www_form(params)
    end.to_s
  end
end
