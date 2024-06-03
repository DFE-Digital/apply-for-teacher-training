class OmniauthCallbacksController < ApplicationController
  # Differentiate web requests sent to BigQuery via dfe-analytics
  def current_namespace
    "access-your-teaching-qualifications"
  end

  def complete
    auth = request.env["omniauth.auth"]
    puts "auth"
    puts "auth"
    puts "auth"
    puts auth
    #candidate = Candidate.find_by_email(auth.info.email)

    #  redirect_to continuous_applications_choices_path
    #if candidate
    #  redirect_to continuous_applications_choices_path
    #else
    #  redirect_to candidate_interface_create_account_or_sign_in_path
    #end
    #provider = auth.provider
    #@user = User.from_auth(auth)
    #session[:"#{provider}_user_id"] = @user.id
    #session[:"#{provider}_user_token"] = auth.credentials.token
    #session[:"#{provider}_user_token_expiry"] = auth.credentials.expires_in.seconds.from_now.to_i
    #session[:"#{provider}_id_token"] = auth.credentials.id_token

    #log_auth_credentials_in_development(auth)
    #redirect_to qualifications_dashboard_path
  end

  def sign_out
    reset_session
    redirect_to "/auth/onelogin/logout"
  end

  def sign_out_complete
    rediret_to candidate_interface_create_account_or_sign_in_path
  end

  private

  def log_auth_credentials_in_development(auth)
    if Rails.env.development?
      Rails.logger.debug auth.credentials.token
      Rails.logger.debug Time.zone.at auth.credentials.expires_in
    end
  end
end
