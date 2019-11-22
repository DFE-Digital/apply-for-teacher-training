module ProviderInterface
  class ProviderInterfaceController < ActionController::Base
    include BasicAuthHelper
    before_action :authenticate_provider_user!
    layout 'application'

    rescue_from MissingProvider, with: ->(e) {
      Raven.extra_context dfe_sign_in_uid: current_provider_user.dfe_sign_in_uid
      Raven.capture_exception(e)

      render template: 'provider_interface/account_creation_in_progress', status: 403
    }

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
