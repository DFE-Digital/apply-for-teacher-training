module ProviderInterface
  class SessionsController < ProviderInterfaceController
    skip_before_action :authenticate_provider_user!
    protect_from_forgery except: :bypass_callback

    def new; end

    def callback
      dfe_sign_in_session = DfESignIn.parse_auth_hash(request.env['omniauth.auth'])
      ProviderUser.begin_session!(session, dfe_sign_in_session)

      redirect_to provider_interface_path
    end

    def destroy
      ProviderUser.end_session!(session)

      redirect_to action: :new
    end

    alias :bypass_callback :callback
  end
end
