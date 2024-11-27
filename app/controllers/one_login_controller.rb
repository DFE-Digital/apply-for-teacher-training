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
    session[:onelogin_error] = 'We cannot log you in, please contact support'
    redirect_to auth_onelogin_sign_out_path
  end

  def sign_out
    id_token = session[:onelogin_id_token] ## save this on the one login auth?
    # this is needed to logout the user, to log him out in apply not one login
    # it's needed so that one login redirects back to us, sign_out_complete

    redirect_to logout_onelogin_path(id_token_hint: id_token)
  end

  def sign_out_complete
    error = session[:onelogin_error]
    reset_session

    flash[:warning] = error if error
    redirect_to candidate_interface_create_account_or_sign_in_path
  end
end
