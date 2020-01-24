class DfESignInController < ActionController::Base
  protect_from_forgery except: :bypass_callback

  def callback
    DfESignInUser.begin_session!(session, request.env['omniauth.auth'])

    user = get_support_user || ProviderUser.load_from_session(session)
    DsiProfile.update_profile_from_dfe_sign_in(dfe_user: DfESignInUser.load_from_session(session), local_user: user) if user

    redirect_to session.delete('post_dfe_sign_in_path') || default_authenticated_path
  end

  alias :bypass_callback :callback

private

  def default_authenticated_path
    if get_support_user
      support_interface_path
    else
      provider_interface_path
    end
  end

  def get_support_user
    @user != nil ? @user : @user = (SupportUser.load_from_session(session) || false)
  end
end
