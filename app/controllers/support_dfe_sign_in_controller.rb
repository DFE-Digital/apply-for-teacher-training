class SupportDfESignInController < ApplicationController
  include DsiSupportAuth

  skip_before_action :require_authentication
  protect_from_forgery except: :bypass_callback

  SESSION_KEYS_TO_FORGET_WITH_EACH_LOGIN = %w[session_id impersonated_provider_user].freeze

  def callback
    if FeatureFlag.active?(:dsi_stateful_session)
      new_callback
    else
      old_callback
    end
  end

  alias bypass_callback callback

  def destroy
    if FeatureFlag.active?(:dsi_stateful_session)
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
    else
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
    end
    redirect_to post_signout_redirect, allow_other_host: true
  end

  # This is called by a redirect from DfE Sign-in after visiting the signout
  # link on DSI. We tell DSI to redirect here using the
  # post_logout_redirect_uri parameter - see DfESignInUser#dsi_logout_url
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

  def new_callback
    change_session_id_and_drop_provider_impersonation
    omniauth_payload = request.env['omniauth.auth']
    dfe_sign_in_uid = omniauth_payload['uid']
    @local_user = SupportUser.kept.find_by(dfe_sign_in_uid:)
    @target_path = session['post_dfe_sign_in_path']

    if @local_user &&
       DsiProfile.update_profile_from_dfe_sign_in_db(omniauth_payload:, local_user: @local_user)
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

  def old_callback
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
      session['unauthorized_dsi_support_uid'] = @dfe_sign_in_user&.dfe_sign_in_uid
      redirect_to auth_dfe_support_destroy_path
    end
  end

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
