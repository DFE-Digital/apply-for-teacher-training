class ProviderDfESignInController < ActionController::Base
  include DsiProviderAuth

  skip_before_action :require_authentication
  protect_from_forgery except: :bypass_callback

  SESSION_KEYS_TO_FORGET_WITH_EACH_LOGIN = %w[session_id impersonated_provider_user].freeze

  def callback
    change_session_id_and_drop_provider_impersonation
    omniauth_payload = request.env['omniauth.auth']
    @local_user ||= ProviderUser.find_or_onboard(omniauth_payload)
    @target_path = session['post_dfe_sign_in_path']

    if @local_user &&
       DsiProfile.update_profile_from_omniauth_payload(omniauth_payload:, local_user: @local_user)
      start_new_dsi_session(
        user: @local_user,
        omniauth_payload:,
      )
      send_provider_sign_in_confirmation_email

      redirect_to target_path_is_provider_path ? @target_path : provider_interface_path
      session.delete('post_dfe_sign_in_path')
    else
      session['email_address_not_recognised'] = omniauth_payload.dig('info', 'email')
      session['id_token'] = omniauth_payload.dig('credentials', 'id_token')

      redirect_to auth_dfe_destroy_path
    end
  end

  alias bypass_callback callback

  def destroy
    id_token = authenticated? ? Current.provider_session&.id_token : session['id_token']
    post_signout_redirect = if id_token.blank?
                              auth_dfe_sign_out_path
                            else
                              query = {
                                post_logout_redirect_uri: auth_dfe_sign_out_url,
                                id_token_hint: id_token,
                              }
                              "#{ENV.fetch('DFE_SIGN_IN_ISSUER')}/session/end?#{query.to_query}"
                            end

    terminate_session
    redirect_to post_signout_redirect, allow_other_host: true
  end

  # This is called by a redirect from DfE Sign-in after visiting the signout
  # link on DSI. We tell DSI to redirect here using the
  # post_logout_redirect_uri parameter
  def redirect_after_dsi_signout
    if session['email_address_not_recognised']
      # When users input an unauthorized email we need to render a page where
      # we show the user's email. We don't have access to the user here because
      # we logged them out by now, so we need to get it from the session variable
      @email_address = session.delete('email_address_not_recognised')
      render(
        layout: 'application',
        template: 'provider_interface/email_address_not_recognised',
        status: :forbidden,
      )
    else
      redirect_to provider_interface_path
    end
  end

private

  def change_session_id_and_drop_provider_impersonation
    existing_values = session.to_hash # e.g. candidate/devise login, cookie consent
    reset_session # prevents session fixation attacks and impersonation bugs
    session.update existing_values.except(*SESSION_KEYS_TO_FORGET_WITH_EACH_LOGIN)
  end

  def send_provider_sign_in_confirmation_email
    return if cookies.signed[:sign_in_confirmation] == @local_user.id

    cookies.signed[:sign_in_confirmation] = {
      value: @local_user.id,
      expires: 6.months.from_now,
      httponly: true,
      secure: Rails.env.production?,
    }

    ProviderMailer.confirm_sign_in(
      @local_user,
      timestamp: Time.zone.now,
    ).deliver_later
  end

  def target_path_is_provider_path
    @target_path&.match(/^#{provider_interface_path}/)
  end
end
