module ProviderInterface
  class SessionsController < ProviderInterfaceController
    skip_before_action :authenticate_provider_user!
    protect_from_forgery except: :bypass_callback

    def new; end

    def callback
      auth_hash = request.env['omniauth.auth']

      session['provider_user'] = {
        'email_address' => auth_hash['info']['email'],
      }

      redirect_to provider_interface_path
    end

    alias :bypass_callback :callback
  end
end
