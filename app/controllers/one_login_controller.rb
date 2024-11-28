class OneLoginController < ApplicationController
  def callback
    auth = request.env['omniauth.auth']
    candidate, error = OneLoginUser.authentificate(auth)
    session[:onelogin_id_token] = auth.credentials.id_token

    if error.nil?
      sign_in(candidate, scope: :candidate)
      candidate.update!(last_signed_in_at: Time.zone.now)

      redirect_to root_path # redirect to where the user wanted to go?
    else
      # reset session and logout
      flash[:warning] = error.message
      ### All the redirects will lose the flash messages
      ### can we sign out only if the user is signed in? Does Devise have a signed_in? method?
      redirect_to auth_onelogin_sign_out_path
    end
  end

  def sign_out
    id_token = session[:onelogin_id_token] ## save this on the one login auth?
    # this is needed to logout the user, to log him out in apply not one login
    # it's needed so that one login redirects back to us, sign_out_complete
    reset_session

    redirect_to logout_onelogin_path(id_token_hint: id_token)
  end

  def sign_out_complete
    redirect_to candidate_interface_create_account_or_sign_in_path
  end
end
