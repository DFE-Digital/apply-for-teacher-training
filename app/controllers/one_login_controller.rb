class OneLoginController < ApplicationController
  include Authentication

  before_action :redirect_to_candidate_sign_in_unless_one_login_enabled
  allow_unauthenticated_access
  # We need to allow requests to these endpoints without requiering authentication to be able to login the candidate and also log out the candidate by just calling these endpoints.
  # There are cases where the user is logged in in one admin but not in our system because of an error in our system, so we need to be able to call sign-out endpoint to log them out of one login

  ## after sign in candidate contoller needs redirect if one login?

  def callback
    auth = request.env['omniauth.auth']
    # session[:one_login_id_token] = auth&.credentials&.id_token

    candidate = OneLoginUser.authenticate_or_create_by(auth)

    start_new_session_for(
      candidate:,
      id_token_hint: auth&.credentials&.id_token,
    )
    #sign_in_candidate(candidate)

    redirect_to candidate_interface_interstitial_path
  rescue OneLoginUser::Error => e
    # We can't attach an error message to the session because in some cases we don't create a session if there's an error
    session[:one_login_error] = e.message
    redirect_to auth_one_login_sign_out_path
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
    id_token_hint = Current.session&.id_token_hint
    one_login_error = session[:one_login_error]
    #reset_session how do we handle the one login error?

    terminate_session

    ## how do you sign out when users are logged in and we switch off the
    ## one login feature flag

    byebug
    session[:one_login_error] = one_login_error
    if OneLogin.bypass? || id_token_hint.nil?
      redirect_to candidate_interface_create_account_or_sign_in_path
    else
      # Go back to one login to sign out the user on their end as well
      redirect_to logout_one_login(id_token_hint), allow_other_host: true
    end
  end

  def sign_out_complete
    if session[:one_login_error].present?
      Sentry.capture_message(session[:one_login_error], level: :error)
      redirect_to internal_server_error_path
    else
      redirect_to candidate_interface_create_account_or_sign_in_path
    end
  end

  def failure
    session[:one_login_error] = "One login failure with #{params[:message]} " \
                                "for one_login_id_token: #{session[:one_login_id_token]}"

    redirect_to auth_one_login_sign_out_path
  end

private

  def redirect_to_candidate_sign_in_unless_one_login_enabled
    if FeatureFlag.inactive?(:one_login_candidate_sign_in)
      redirect_to candidate_interface_create_account_or_sign_in_path
    end
  end

  def sign_in_candidate(candidate)
    sign_in(candidate, scope: :candidate)
    candidate.update!(last_signed_in_at: Time.zone.now)
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
