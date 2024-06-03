class OmniauthCallbacksController < ApplicationController
  def complete
    auth = request.env["omniauth.auth"]
    candidate = Candidate.find_by_email_address(auth.info.email)
    session[:onelogin_id_token] = auth.credentials.id_token

    if candidate
      puts "Candidate #{candidate.email_address}"
      redirect_to candidate_interface_create_account_or_sign_in_path
    else
      raise "Candidate not found"
    end

  end

  def sign_out
    id_token = session[:onelogin_id_token]
    reset_session

    redirect_to "/auth/onelogin/logout?id_token_hint=#{id_token}"
  end

  def sign_out_complete
    redirect_to candidate_interface_create_account_or_sign_in_path
  end
end
