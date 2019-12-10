class DfESignInController < ActionController::Base
  protect_from_forgery except: :bypass_callback

  def callback
    dfe_sign_in_session = DfESignIn.parse_auth_hash(request.env['omniauth.auth'])
    DfESignInUser.begin_session!(session, dfe_sign_in_session)

    redirect_to session.delete('post_dfe_sign_in_path') || default_authenticated_path
  end

  alias :bypass_callback :callback

private

  def default_authenticated_path
    if authorized_for_support_interface?
      support_interface_path
    else
      provider_interface_path
    end
  end

  def authorized_for_support_interface?
    SupportUser.load_from_session(session)
  end
end
