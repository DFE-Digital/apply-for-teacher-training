class OneLoginController < ApplicationController
  def callback
    auth = request.env['omniauth.auth']
    session[:onelogin_id_token] = auth.credentials.id_token
    candidate = OneLoginUser.authentificate(auth)

    sign_in(candidate, scope: :candidate)
    candidate.update!(last_signed_in_at: Time.zone.now)

    redirect_to candidate_interface_interstitial_path
  rescue OneLoginUser::Error => e
    Sentry.capture_exception(e)
    flash[:warning] = 'We cannot log you in, please contact support'
    redirect_to auth_onelogin_sign_out_path
  end

  def sign_out
    id_token = session[:onelogin_id_token]
    redirect_to logout_onelogin_path(id_token_hint: id_token)
  end

  def sign_out_complete
    saved_flash_state = flash
    reset_session

    flash[:warning] = saved_flash_state[:warning] if saved_flash_state[:warning].present?
    redirect_to candidate_interface_create_account_or_sign_in_path
  end
end
