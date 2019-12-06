module SupportInterface
  class SupportInterfaceController < ActionController::Base
    include LogQueryParams

    layout 'support_layout'
    before_action :authenticate_support_user!

    helper_method :current_support_user, :dfe_sign_in_user

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
      @current_support_user ||= SupportUser.load_from_session(session)
    end

    def dfe_sign_in_user
      ProviderUser.load_from_session(session)
    end

    def authenticate_support_user!
      return if current_support_user

      session['post_dfe_sign_in_path'] = request.path

      if !current_support_user && dfe_sign_in_user
        render(
          template: 'support_interface/unauthorized',
          status: 403,
        )
        return
      end

      session['post_dfe_sign_in_path'] = request.path
      redirect_to support_interface_sign_in_path
    end
  end
end
