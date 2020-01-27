class DfESignInController < ActionController::Base
  protect_from_forgery except: :bypass_callback

  def callback
    DfESignInUser.begin_session!(session, request.env['omniauth.auth'])
    dfe_sign_in_user = DfESignInUser.load_from_session(session)
    @target_path = session['post_dfe_sign_in_path']
    @local_user = get_local_user

    if @local_user
      DsiProfile.update_profile_from_dfe_sign_in(dfe_user: dfe_sign_in_user, local_user: @local_user)
      @local_user.update!(last_signed_in_at: Time.zone.now)
      redirect_to @target_path ? session.delete('post_dfe_sign_in_path') : default_authenticated_path
    else
      DfESignInUser.end_session!(session)
      render(
        layout: 'application',
        template: 'provider_interface/account_creation_in_progress',
        status: :forbidden,
      )
    end
  end

  alias :bypass_callback :callback

private

  def get_local_user
    @target_path && @target_path.match(/^#{support_interface_path}/) ? get_support_user : get_provider_user
  end

  def get_support_user
    @support_user != nil ? @support_user : @support_user = (SupportUser.load_from_session(session) || false)
  end

  def get_provider_user
    @provider_user != nil ? @provider_user : @provider_user = (ProviderUser.load_from_session(session) || false)
  end

  def default_authenticated_path
    if @local_user.is_a?(SupportUser)
      support_interface_path
    else
      provider_interface_path
    end
  end
end
