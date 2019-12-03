module ProviderInterface
  class SessionsController < ProviderInterfaceController
    skip_before_action :authenticate_provider_user!
    protect_from_forgery except: :bypass_callback

    def new; end

    def callback
      dfe_sign_in_session = DfESignIn.parse_auth_hash(request.env['omniauth.auth'])
      DfESignInUser.begin_session!(session, dfe_sign_in_session)

      # TODO: What if the given user doesn't have permission to visit
      # the provider interface?
      redirect_to session.delete('post_dfe_sign_in_path') || provider_interface_path
    end

    def destroy
      DfESignInUser.end_session!(session)

      redirect_to action: :new
    end

    alias :bypass_callback :callback
  end
end
