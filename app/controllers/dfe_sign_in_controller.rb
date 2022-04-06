class DfESignInController < ActionController::Base
  protect_from_forgery except: :bypass_callback

  SESSION_KEYS_TO_FORGET_WITH_EACH_LOGIN = %w[session_id impersonated_provider_user].freeze

  def callback
    change_session_id_and_drop_provider_impersonation
    DfESignInUser.begin_session!(session, request.env['omniauth.auth'])
    @dfe_sign_in_user = DfESignInUser.load_from_session(session)
    @target_path = session['post_dfe_sign_in_path']
    @local_user = local_user

    if @local_user
      DsiProfile.update_profile_from_dfe_sign_in(dfe_user: @dfe_sign_in_user, local_user: @local_user)
      @local_user.update!(last_signed_in_at: Time.zone.now)

      if @local_user.is_a?(SupportUser)
        send_support_sign_in_confirmation_email
      elsif @local_user.is_a?(ProviderUser)
        send_provider_sign_in_confirmation_email
      end

      redirect_to @target_path ? session.delete('post_dfe_sign_in_path') : default_authenticated_path
    else
      DfESignInUser.end_session!(session)
      render(
        layout: 'application',
        template: choose_error_template,
        status: :forbidden,
      )
    end
  end

  alias bypass_callback callback

  # This is called by a redirect from DfE Sign-in after visiting the signout
  # link on DSI. We tell DSI to redirect here using the
  # post_logout_redirect_uri parameter - see DfESignInUser#dsi_logout_url
  #
  # The interface we signed out from will appear here in the :state param.
  def redirect_after_dsi_signout
    if params[:state] == 'support'
      redirect_to support_interface_path
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
        ip_address: request.remote_ip,
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
end
