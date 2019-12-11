module SupportInterface
  class SupportInterfaceController < ActionController::Base
    include LogQueryParams

    layout 'support_layout'
    before_action :authenticate_support_user!
    before_action :add_identity_to_log

    helper_method :current_support_user, :dfe_sign_in_user

    def current_support_user
      SupportUser.load_from_session(session)
    end

    def dfe_sign_in_user
      DfESignInUser.load_from_session(session)
    end

    alias :audit_user :current_support_user

  private

    def protect_with_basic_auth
      authenticate_or_request_with_http_basic do |username, password|
        (username == ENV.fetch('SUPPORT_USERNAME')) && (password == ENV.fetch('SUPPORT_PASSWORD'))
      end
    end

    def render_404
      render 'errors/not_found', status: :not_found
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

    def add_identity_to_log
      return unless current_support_user

      RequestLocals.store[:identity] = { support_user_id: current_support_user.id }
      Raven.user_context(support_user_id: current_support_user.id)
    end
  end
end
