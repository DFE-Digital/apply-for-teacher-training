class OneLoginController < ApplicationController
  before_action :one_login_enabled

  rescue_from OneLoginUser::Error, with: :render_500

  def callback
    auth = request.env['omniauth.auth']
    session[:onelogin_id_token] = auth.credentials.id_token
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
    redirect_to logout_onelogin_path(id_token_hint: id_token)
  end

  def sign_out_complete
    one_login_error = session[:one_login_error]
    reset_session

    if one_login_error.present?
      Sentry.capture_message(one_login_error)
      raise OneLoginUser::Error
    end

    redirect_to candidate_interface_create_account_or_sign_in_path
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
end
