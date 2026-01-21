class SupportDfESignInController < ApplicationController
  include DsiSupportAuth

  skip_before_action :require_authentication
  protect_from_forgery except: :bypass_callback

  SESSION_KEYS_TO_FORGET_WITH_EACH_LOGIN = %w[session_id impersonated_provider_user].freeze

  def callback
    change_session_id_and_drop_provider_impersonation
    omniauth_payload = request.env['omniauth.auth']
    dfe_sign_in_uid = omniauth_payload['uid']
    @local_user = SupportUser.kept.find_by(dfe_sign_in_uid:)
    @target_path = session['post_dfe_sign_in_path']

    if @local_user &&
       DsiProfile.update_profile_from_omniauth_payload(omniauth_payload:, local_user: @local_user)
      start_new_dsi_session(
        user: @local_user,
        omniauth_payload:,
      )

      send_support_sign_in_confirmation_email

      redirect_to target_path_is_support_path ? @target_path : support_interface_path
      session.delete('post_dfe_sign_in_path')
    else
      session['unauthorized_dsi_support_uid'] = dfe_sign_in_uid

      session['id_token'] = omniauth_payload.dig('credentials', 'id_token')
      redirect_to auth_dfe_support_destroy_path
    end
  end

  alias bypass_callback callback

  def destroy
    id_token = authenticated? ? Current.support_session&.id_token : session['id_token']
    post_signout_redirect = if id_token.blank?
                              auth_dfe_support_sign_out_path
                            else
                              query = {
                                post_logout_redirect_uri: auth_dfe_support_sign_out_url,
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
    # When users are not authorized we need to render a page where
    # we show the user's dfe_sign_in_uid. We don't have access to the user here because
    # we logged them out by now, so we need to get it from the session variable
    if session['unauthorized_dsi_support_uid'].present?
      @dfe_sign_in_uid = session.delete('unauthorized_dsi_support_uid')
      session.delete('id_token')
      render(
        layout: 'application',
        template: 'support_interface/unauthorized',
        status: :forbidden,
      )
    else
      redirect_to support_interface_sign_in_path
    end
  end

private

  def change_session_id_and_drop_provider_impersonation
    existing_values = session.to_hash # e.g. candidate/devise login, cookie consent
    reset_session # prevents session fixation attacks and impersonation bugs
    session.update existing_values.except(*SESSION_KEYS_TO_FORGET_WITH_EACH_LOGIN)
  end

  def send_support_sign_in_confirmation_email
    return if cookies.signed[:sign_in_confirmation] == @local_user.id

    cookies.signed[:sign_in_confirmation] = {
      value: @local_user.id,
      expires: 20.years.from_now,
      httponly: true,
      secure: Rails.env.production?,
    }

    SupportMailer.confirm_sign_in(
      @local_user,
      device: {
        user_agent: request.user_agent,
        ip_address: user_ip_address,
      },
    ).deliver_later
  end

  def user_ip_address
    # If we are on AKS we need to use the x-real-ip header instead
    # of the remote ip as X-FORWARDED-FOR contains the ip and proxies
    # and Rails is picking the proxy from last to first on remote_ip calls.
    request.headers['x-real-ip'].presence || request.remote_ip
  end

  def target_path_is_support_path
    @target_path&.match(/^#{support_interface_path}/)
  end
end
