class OneLoginController < ApplicationController
  def callback
    auth = request.env['omniauth.auth']
    candidate, error = OneLoginUser.authentificate(auth)

    if error.nil?
      session[:onelogin_id_token] = auth.credentials.id_token

      sign_in(candidate, scope: :candidate)
      candidate.update!(last_signed_in_at: Time.zone.now)

      redirect_to root_path # redirect to where the user wanted to go?
    else
      # reset session and logout
      flash[:warning] = error.message
      redirect_to root_path # redirect to sign in page?
    end
  end

  def sign_out
    puts "SIGN OUT"
    id_token = session[:onelogin_id_token] ## save this on the one login auth?
    reset_session

    redirect_to logout_onelogin_path(id_token_hint: id_token)
  end

  def sign_out_complete
    redirect_to candidate_interface_create_account_or_sign_in_path
  end
end
