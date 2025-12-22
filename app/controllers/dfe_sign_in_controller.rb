class DfESignInController < ActionController::Base
  protect_from_forgery except: :bypass_callback

  SESSION_KEYS_TO_FORGET_WITH_EACH_LOGIN = %w[session_id impersonated_provider_user].freeze

  def callback
    if FeatureFlag.active?(:separate_dsi_controllers)
      new_callback
    else
      old_callback
    end
  end

  alias bypass_callback callback

  def destroy
    dfe_sign_in_user = DfESignInUser.load_from_session(session)
    post_signout_redirect = if dfe_sign_in_user&.needs_dsi_signout?
                              query = {
                                post_logout_redirect_uri: auth_dfe_sign_out_url,
                                id_token_hint: dfe_sign_in_user.id_token,
                              }

                              "#{ENV.fetch('DFE_SIGN_IN_ISSUER')}/session/end?#{query.to_query}"
                            else
                              auth_dfe_sign_out_path
                            end

    DfESignInUser.end_session!(session)
    redirect_to post_signout_redirect, allow_other_host: true
  end

  # This is called by a redirect from DfE Sign-in after visiting the signout
  # link on DSI. We tell DSI to redirect here using the
  # post_logout_redirect_uri parameter - see DfESignInUser#dsi_logout_url
  #
  # The interface we signed out from will appear here in the :state param.
  def redirect_after_dsi_signout
    if FeatureFlag.active?(:separate_dsi_controllers) && session['dsi_provider_email']
      @email_address = session.delete('dsi_provider_email')
      render(
        layout: 'application',
        template: 'provider_interface/email_address_not_recognised',
        status: :forbidden,
      )
    elsif params[:state] == 'support'
      redirect_to support_interface_path
    else
      redirect_to provider_interface_path
    end
  end

private

  def new_callback
    change_session_id_and_drop_provider_impersonation
    DfESignInUser.begin_session!(session, request.env['omniauth.auth'])
    @dfe_sign_in_user = DfESignInUser.load_from_session(session)
    @local_user ||= ProviderUser.load_from_session(session) || false
    @target_path = session['post_dfe_sign_in_path']

    if @local_user && DsiProfile.update_profile_from_dfe_sign_in(dfe_user: @dfe_sign_in_user, local_user: @local_user)
      @local_user.update!(last_signed_in_at: Time.zone.now)

      send_provider_sign_in_confirmation_email

      path_to_redirect = if target_path_is_support_path
                           session.delete('post_dfe_sign_in_path')
                           provider_interface_path
                         else
                           session.delete('post_dfe_sign_in_path') || provider_interface_path
                         end

      redirect_to path_to_redirect
    else
      session['dsi_provider_email'] = @dfe_sign_in_user&.email_address
      redirect_to auth_dfe_destroy_path
    end
  end

  def old_callback
    change_session_id_and_drop_provider_impersonation
    DfESignInUser.begin_session!(session, request.env['omniauth.auth'])
    @dfe_sign_in_user = DfESignInUser.load_from_session(session)
    @target_path = session['post_dfe_sign_in_path']
    @local_user = local_user

    if @local_user && DsiProfile.update_profile_from_dfe_sign_in(dfe_user: @dfe_sign_in_user, local_user: @local_user)
      @local_user.update!(last_signed_in_at: Time.zone.now)

      if @local_user.is_a?(SupportUser)
        send_support_sign_in_confirmation_email
      elsif @local_user.is_a?(ProviderUser)
        send_provider_sign_in_confirmation_email
      end

      redirect_to @target_path ? session.delete('post_dfe_sign_in_path') : default_authenticated_path
    else
      @email_address = dfe_sign_in_user&.email_address
      DfESignInUser.end_session!(session)
      render(
        layout: 'application',
        template: 'provider_interface/email_address_not_recognised',
        status: :forbidden,
      )
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

  def local_user
    target_path_is_support_path ? support_user : provider_user
  end

  def support_user
    @support_user ||= SupportUser.load_from_session(session) || false
  end

  def provider_user
    @provider_user ||= ProviderUser.load_from_session(session) || false
  end

  def default_authenticated_path
    if @local_user.is_a?(SupportUser)
      support_interface_path
    else
      provider_interface_path
    end
  end

  def choose_error_template
    if target_path_is_support_path
      'support_interface/unauthorized'
    else
      'provider_interface/email_address_not_recognised'
    end
  end

  def target_path_is_support_path
    @target_path&.match(/^#{support_interface_path}/)
  end

  def user_ip_address
    # If we are on AKS we need to use the x-real-ip header instead
    # of the remote ip as X-FORWARDED-FOR contains the ip and proxies
    # and Rails is picking the proxy from last to first on remote_ip calls.
    request.headers['x-real-ip'].presence || request.remote_ip
  end
end
