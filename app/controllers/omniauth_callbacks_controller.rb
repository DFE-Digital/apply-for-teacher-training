class OmniauthCallbacksController < ApplicationController
  def complete
    auth = request.env['omniauth.auth']
    email_address = auth.info.email
    one_login_uid = auth.uid

    candidate = Candidate.find_by(one_login_uid: one_login_uid) || Candidate.find_by(email_address: email_address)

    if candidate
      candidate.update!(one_login_uid: one_login_uid) if candidate.one_login_uid.nil?
    else
      candidate = Candidate.create(email_address: email_address, one_login_uid: one_login_uid)
    end

    session[:onelogin_id_token] = auth.credentials.id_token
    candidate.update!(last_signed_in_at: Time.zone.now) if sign_in(candidate, scope: :candidate)

    redirect_to root_path
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
