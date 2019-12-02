module SupportInterface
  class SupportInterfaceController < ActionController::Base
    include LogQueryParams

    layout 'support_layout'
    before_action :authenticate_support_user!

    helper_method :current_support_user

  private

    def protect_with_basic_auth
      authenticate_or_request_with_http_basic do |username, password|
        (username == ENV.fetch('SUPPORT_USERNAME')) && (password == ENV.fetch('SUPPORT_PASSWORD'))
      end
    end

    def render_404
      render 'errors/not_found', status: :not_found
    end

    def current_support_user
      SupportUser.load_from_session(session)
    end

    def authenticate_support_user!
      redirect_to support_interface_sign_in_path unless current_support_user
    end
  end
end
