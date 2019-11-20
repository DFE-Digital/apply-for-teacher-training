module ProviderInterface
  class ProviderInterfaceController < ActionController::Base
    include BasicAuthHelper
    before_action :authenticate_provider_user!
    layout 'application'

    helper_method :current_provider_user

  private

    def current_provider_user
      ProviderUser.load_from_session(session)
    end

    def authenticate_provider_user!
      redirect_to provider_interface_sign_in_path unless current_provider_user
    end
  end
end
