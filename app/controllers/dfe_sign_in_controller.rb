class DfESignInController < ActionController::Base
  protect_from_forgery except: :bypass_callback

  def callback
    DfESignInUser.begin_session!(session, request.env['omniauth.auth'])

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
