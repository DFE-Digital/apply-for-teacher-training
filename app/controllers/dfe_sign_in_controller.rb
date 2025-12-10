class DfESignInController < ActionController::Base
  include DfESigninAuth

  skip_before_action :require_authentication

  protect_from_forgery except: :bypass_callback

  SESSION_KEYS_TO_FORGET_WITH_EACH_LOGIN = %w[session_id impersonated_provider_user].freeze

  def callback
    change_session_id_and_drop_provider_impersonation
    # what is this doing?

    omniauth_payload = request.env['omniauth.auth']
    dfe_sign_in_uid = omniauth_payload['uid']

    user = if candidate_interface?
             SupportUser.find_by(dfe_sign_in_uid:)
           else
             ProviderUser.find_by(dfe_sign_in_uid:)
           end
    @local_user = user

    if @local_user
      start_new_dsi_session(
        user:,
        omniauth_payload:,
      )
      profile = DsiProfile.update_profile_from_dfe_sign_in_db(
        dfe_user: Current.dfe_session,
        local_user: @local_user,
      ) # do we need this?
    end

    @target_path = session['post_dfe_sign_in_path'] # should we remove this and use something else?

    # we need to catch standard errors like in one login controller

    if @local_user && profile
      @local_user.update!(last_signed_in_at: Time.zone.now)

      if @local_user.is_a?(SupportUser)
        # New sign in to Support for Apply for teacher training
        send_support_sign_in_confirmation_email
      elsif @local_user.is_a?(ProviderUser)
        # New sign in to Provider for Manage for teacher training
        send_provider_sign_in_confirmation_email
      end

      # redirect_to @target_path ? session.delete('post_dfe_sign_in_path') : default_authenticated_path
      # check redirection to request.referrer
      redirect_to @target_path || default_authenticated_path
    else
      terminate_session
      # DfESignInUser.end_session!(session)
      # use target_path to redirect to correct controller.
      # If we just render we will end up on the wrong path
      @dfe_sign_in_uid = dfe_sign_in_uid
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
    # what is this?
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

  def default_authenticated_path
    # use interface?
    if @local_user.is_a?(SupportUser)
      support_interface_path
    else
      provider_interface_path
    end
  end

  def choose_error_template
    #if candidate_interface?
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
