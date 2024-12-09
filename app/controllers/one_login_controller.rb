class OneLoginController < ApplicationController
  before_action :one_login_enabled
  before_action :set_sentry_context, only: :callback

  def callback
    auth = request.env['omniauth.auth']
    session[:onelogin_id_token] = auth&.credentials&.id_token
    candidate = OneLoginUser.authentificate(auth)

    sign_in(candidate, scope: :candidate)
    candidate.update!(last_signed_in_at: Time.zone.now)

    redirect_to candidate_interface_interstitial_path
  rescue OneLoginUser::Error => e
    session[:one_login_error] = e.message
    redirect_to auth_onelogin_sign_out_path
  end

  def sign_out
    id_token = session[:onelogin_id_token]
    one_login_error = session[:one_login_error]
    reset_session

    session[:one_login_error] = one_login_error
    # Go back to one login to sign out the user on their end as well
    redirect_to logout_onelogin_path(id_token_hint: id_token)
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
                                "for onelogin_id_token: #{session[:onelogin_id_token]}"

    redirect_to auth_onelogin_sign_out_path
  end

private

  def one_login_enabled
    return if FeatureFlag.active?(:one_login_candidate_sign_in)

    redirect_to root_path
  end

  def set_sentry_context
    Sentry.set_extras(
      omniauth_hash: request.env['omniauth.auth'].to_h,
    )
  end
end
