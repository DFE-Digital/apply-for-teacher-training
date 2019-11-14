module ProviderInterface
  class ProviderInterfaceController < ActionController::Base
    include BasicAuthHelper
    before_action :authenticate_provider_user!
    layout 'application'

    helper_method :current_provider_user

  private

    # Stub out the current user and their organisation. Will be replaced
    # by a proper ProviderUser when implementing Signin.
    def current_provider_user
      if session['provider_user']
        fake_user_class = Struct.new(:provider, :email_address)
        fake_provider = Provider.find_by(code: 'ABC')

        fake_user_class.new(
          fake_provider,
          session['provider_user']['email_address'],
        )
      end
    end

    def authenticate_provider_user!
      redirect_to provider_interface_sign_in_path unless current_provider_user
    end
  end
end
