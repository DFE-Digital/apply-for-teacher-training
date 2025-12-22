class SupportDfESignInController < ApplicationController
  protect_from_forgery except: :bypass_callback

  SESSION_KEYS_TO_FORGET_WITH_EACH_LOGIN = %w[session_id impersonated_provider_user].freeze

  def callback
    redirect_to auth_dfe_callback_path and return unless FeatureFlag.active?(:separate_dsi_controllers)

    change_session_id_and_drop_provider_impersonation
    DfESignInUser.begin_session!(session, request.env['omniauth.auth'])
    @dfe_sign_in_user = DfESignInUser.load_from_session(session)
    @local_user ||= SupportUser.load_from_session(session) || false
    @target_path = session['post_dfe_sign_in_path']

    if @local_user && DsiProfile.update_profile_from_dfe_sign_in(dfe_user: @dfe_sign_in_user, local_user: @local_user)
      @local_user.update!(last_signed_in_at: Time.zone.now)

      send_support_sign_in_confirmation_email

      redirect_to target_path_is_support_path ? @target_path : support_interface_path
      session.delete('post_dfe_sign_in_path')
    else
      session['dsi_support_uid'] = @dfe_sign_in_user&.dfe_sign_in_uid
      redirect_to auth_dfe_support_destroy_path
    end
  end

  def destroy
    dfe_sign_in_user = DfESignInUser.load_from_session(session)
    post_signout_redirect = if dfe_sign_in_user&.needs_dsi_signout?
                              query = {
                                post_logout_redirect_uri: auth_dfe_support_sign_out_url,
                                id_token_hint: dfe_sign_in_user.id_token,
                              }

                              "#{ENV.fetch('DFE_SIGN_IN_ISSUER')}/session/end?#{query.to_query}"
                            else
                              auth_dfe_support_sign_out_path
                            end

    DfESignInUser.end_session!(session)
    redirect_to post_signout_redirect, allow_other_host: true
  end

  alias bypass_callback callback

  # This is called by a redirect from DfE Sign-in after visiting the signout
  # link on DSI. We tell DSI to redirect here using the
  # post_logout_redirect_uri parameter - see DfESignInUser#dsi_logout_url
  #
  # The interface we signed out from will appear here in the :state param.
  def redirect_after_dsi_signout
    if session['dsi_support_uid'].present?
      @dfe_sign_in_uid = session.delete('dsi_support_uid')
      render(
        layout: 'application',
        template: 'support_interface/unauthorized',
        status: :forbidden,
      )
    else
      redirect_to support_interface_path
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
