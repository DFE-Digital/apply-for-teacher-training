load Blazer::Engine.root.join('app/controllers/blazer/base_controller.rb')

module Blazer
  class BaseController
    include DsiSupportAuth
    include Pundit::Authorization

    rescue_from Pundit::NotAuthorizedError, with: :handle_unauthorised

    before_action :authorize_blazer_access!

  private

    def authorize_blazer_access!
      authorize current_user, policy_class: ::SupportInterface::DeveloperToolPolicy
    end

    def current_user
      return @current_support_user if defined?(@current_support_user)

      @current_support_user ||= Current.support_session&.user ||
                                find_session_by_cookie&.support_user
    end

    def handle_unauthorised
      flash[:info] = 'You are not authorized to perform this action.'

      redirect_to main_app.support_interface_path
    end
  end
end
